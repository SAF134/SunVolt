const express = require('express');
const midtransClient = require('midtrans-client');
const cors = require('cors');
const admin = require('firebase-admin');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

// --- KONFIGURASI FIREBASE ADMIN ---
// Pastikan file serviceAccountKey.json ada di folder 'backend'
try {
    const serviceAccount = require("./serviceAccountKey.json");
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
    console.log("Firebase Admin Berhasil diinisialisasi.");
} catch (error) {
    console.error("EROR: File serviceAccountKey.json tidak ditemukan atau tidak valid!");
}
const db = admin.firestore();

// --- KONFIGURASI MIDTRANS ---
let snap = new midtransClient.Snap({
    isProduction: false,
    serverKey: process.env.MIDTRANS_SERVER_KEY,
    clientKey: process.env.MIDTRANS_CLIENT_KEY
});

// --- ENDPOINT: MEMBUAT TRANSAKSI ---
app.post('/api/create-transaction', async (req, res) => {
    try {
        const { amount, orderId, customerName, customerEmail, userId } = req.body;

        let parameter = {
            "transaction_details": {
                "order_id": orderId,
                "gross_amount": amount
            },
            "customer_details": {
                "first_name": customerName,
                "email": customerEmail
            },
            "expiry": {
                "unit": "minutes",
                "duration": 30
            }
        };

        const transaction = await snap.createTransaction(parameter);

        // Simpan data transaksi di Firestore agar webhook bisa menemukan user
        await db.collection('transactions').doc(orderId).set({
            orderId: orderId,
            userId: userId || '',
            amount: amount,
            customerEmail: customerEmail,
            status: 'pending',
            createdAt: admin.firestore.FieldValue.serverTimestamp()
        });

        res.json({
            token: transaction.token,
            redirect_url: transaction.redirect_url
        });
    } catch (error) {
        console.error('Midtrans Create Error Full:', error);
        res.status(500).json({ 
            error: 'Gagal membuat transaksi',
            message: error.message,
            details: error.ApiResponse || error
        });
    }
});

// --- WEBHOOK: CALLBACK DARI MIDTRANS ---
app.post('/api/midtrans-callback', async (req, res) => {
    try {
        const statusResponse = req.body;
        const transactionStatus = statusResponse.transaction_status;
        const fraudStatus = statusResponse.fraud_status;
        const amount = parseInt(statusResponse.gross_amount);
        const orderId = statusResponse.order_id;

        console.log(`Notifikasi: Order: ${orderId}, Status: ${transactionStatus}, Amount: ${amount}`);

        if (transactionStatus == 'capture' || transactionStatus == 'settlement') {
            if (fraudStatus == 'accept' || fraudStatus == undefined) {
                
                // Cari transaksi yang tersimpan untuk mendapatkan userId
                const txDoc = await db.collection('transactions').doc(orderId).get();
                
                if (txDoc.exists) {
                    const txData = txDoc.data();
                    const userId = txData.userId;
                    
                    if (userId) {
                        // Update saldo menggunakan FieldValue.increment
                        await db.collection('users').doc(userId).update({
                            balance: admin.firestore.FieldValue.increment(amount)
                        });
                        
                        // Update status transaksi
                        await db.collection('transactions').doc(orderId).update({
                            status: 'settlement',
                            updatedAt: admin.firestore.FieldValue.serverTimestamp()
                        });

                        // Tambahkan ke Riwayat Aktivitas User
                        const formattedAmount = amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
                        await db.collection('users').doc(userId).collection('activity_history').add({
                            title: 'Top-Up Dompet',
                            subtitle: 'QRIS',
                            amount: `+Rp ${formattedAmount}`,
                            isPositive: true,
                            timestamp: admin.firestore.FieldValue.serverTimestamp(),
                            type: 'topup'
                        });
                        
                        console.log(`✅ BERHASIL: Saldo user ${userId} bertambah Rp ${amount}`);
                    }
                } else {
                    // Fallback jika dokumen transaksi tidak ditemukan, coba cari berdasarkan email (jika ada di callback)
                    // Catatan: Midtrans biasanya tidak mengirim email di callback kecuali diatur secara khusus.
                    // Jika data tidak ada, kita log sebagai kegagalan.
                    console.log(`⚠️ WARNING: Transaksi ${orderId} tidak ditemukan di database.`);
                }
            }
        }
        res.status(200).send('OK');
    } catch (error) {
        console.error('❌ Error Webhook:', error);
        res.status(500).send('Internal Server Error');
    }
});

app.get('/', (req, res) => res.send('SunVolt Server is Ready!'));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`🚀 Server berjalan di port ${PORT}`);
});
