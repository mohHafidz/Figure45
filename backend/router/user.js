var express = require("express");

var router = express.Router();

var conn = require('./conn');

router.post('/addCart', (req, resp) => {
    var data = req.body; // Mengambil data dari query string
    var cek = `SELECT * FROM cart WHERE email = '${data.email}' AND barangID = '${data.barangID}'`;
    conn.query(cek, (err, result) => {
        if (err) {
            resp.status(500).send('Terjadi kesalahan pada server');
        } else {
            if (result.length === 0) {
                var query = `INSERT INTO cart  VALUES ('','${data.barangID}',1,'${data.email}')`;
                conn.query(query, (err, result) => {
                    if (err) {
                        // resp.status(500).send('Gagal menambahkan barang ke cart');
                        resp.send(err);
                    } else {
                        resp.status(200).send('Barang berhasil ditambahkan ke cart');
                    }
                });
            } else {
                var jumlahQuery = `SELECT jumlah FROM cart WHERE email = '${data.email}' AND barangID = '${data.barangID}'`;
                conn.query(jumlahQuery, (err, result) => {
                    if (err) {
                        resp.status(500).send('Gagal mendapatkan jumlah barang');
                    } else {
                        if (result.length > 0) {
                            var jumlah = result[0].jumlah; // Ambil nilai jumlah dari hasil query
                            jumlah++; // Tingkatkan nilai jumlah
                
                            var updateQuery = `UPDATE cart SET jumlah = ${jumlah} WHERE email = '${data.email}' AND barangID = '${data.barangID}'`;
                            conn.query(updateQuery, (err, result) => {
                                if (err) {
                                    resp.status(500).send('Gagal menambahkan jumlah barang');
                                } else {
                                    resp.status(200).send('Barang berhasil ditambahkan');
                                }
                            });
                        } else {
                            resp.status(404).send('Data tidak ditemukan');
                        }
                    }
                });
            
            }
        }
    });
});

router.post('/plusCart', (req, resp) => {
    const data = req.body
    console.log(data.cartID);
    var jumlahQuery = `SELECT jumlah FROM cart WHERE email = '${data.email}' AND cartID = ${data.cartID}`;
    conn.query(jumlahQuery, (err, result) => {
        if (err) {
            resp.status(500).send('Gagal mendapatkan jumlah barang');
        } else {
            if (result.length > 0) {
                var jumlah = result[0].jumlah; // Ambil nilai jumlah dari hasil query
                jumlah++; // Tingkatkan nilai jumlah
                
                var updateQuery = `UPDATE cart SET jumlah = ${jumlah} WHERE email = '${data.email}' AND cartID = ${data.cartID}`;
                conn.query(updateQuery, (err, result) => {
                    if (err) {
                        resp.status(500).send('Gagal menambahkan jumlah barang');
                    } else {
                        resp.status(200).send('Barang berhasil ditambahkan');
                    }
                });
            } else {
                resp.status(404).send('Data tidak ditemukan');
            }
        }
    });
});

router.post('/minusCart', (req, resp)=>{
    var data =  req.body; 
    var query = `SELECT jumlah FROM cart WHERE cartID = ${data.cartID} AND email = '${data.email}'`
    conn.query(query, (err, result)=>{
        if (err) {
            resp.status(500).send('Gagal mendapatkan jumlah barang');
        } else {
            if (result.length > 0) {
                var jumlah = result[0].jumlah; // Ambil nilai jumlah dari hasil query
                if(jumlah > 1){
                    jumlah--; // Tingkatkan nilai jumlah
        
                    var updateQuery = `UPDATE cart SET jumlah = ${jumlah} WHERE cartID = ${data.cartID} AND email = '${data.email}'`;
                    conn.query(updateQuery, (err, result) => {
                        if (err) {
                            resp.status(500).send('Gagal mengurangkan jumlah barang');
                        } else {
                            resp.status(200).send('Barang berhasil dikurang');
                        }
                    });
                }else{
                    var deleteQuery = `DELETE FROM cart WHERE cartID = ${data.cartID} AND email = '${data.email}'`;
                    conn.query(deleteQuery, (err, result) => {
                        if (err) {
                            resp.status(500).send('Gagal menghapus jumlah barang');
                        } else {
                            resp.status(200).send('Barang berhasil menghapus');
                        }
                    });
                }
            }
        }
    })
})

router.get('/like/:email', (req, resp)=>{
    const email = req.params.email;
    var query = `SELECT l.barangID, b.namaBarang, b.harga, b.deskripsi, b.gambar, l.ID FROM liked l join barang b on l.barangID = b.ID WHERE l.email like '${email}'`

    conn.query(query, (err, result)=>{
        if(err){
            resp.send(err);
        }else{
            resp.json({ 
                data: result // Kirim data sebagai response
              });
        }
    })
})

router.post('/liked', (req, resp) => {
    const data = req.body;
    var query = `SELECT * FROM liked WHERE email = '${data.email}' AND barangID = ${data.barangID}`;
    
    conn.query(query, (err, result) => {
        if (err) {
            resp.status(500).send(err); // Mengirim status 500 beserta pesan error
        } else {
            if (result.length !== 0) {
                resp.status(200).send(result);
            } else {
                resp.status(500).send('Data not found'); // Mengirim status 500 dengan pesan bahwa data tidak ditemukan
            }
        }
    });
});


router.get('/keranjang/:email', (req, resp)=>{
    const email = req.params.email;
    var query = `SELECT b.harga, c.barangID, b.deskripsi, b.namaBarang, c.jumlah, b.gambar, c.cartID FROM cart c JOIN barang b on b.ID = c.barangID WHERE c.email = '${email}'`

    conn.query(query, (err, result)=>{
        if(err){
            resp.send(err);
        }else{
            resp.json({ 
                data: result // Kirim data sebagai response
              });
        }
    })
})

router.get('/harga/:email', (req, resp)=>{
    const email = req.params.email;
    var query = `SELECT SUM(c.jumlah * b.harga) AS total_harga FROM cart c JOIN barang b on b.ID = c.barangID WHERE c.email = '${email}'`

    conn.query(query, (err, result)=>{
        if(err){
            resp.send(err);
        }else{
            resp.json({ 
                data: result // Kirim data sebagai response
              });
        }
    })
})

router.post('/like', (req, resp)=>{
    var data = req.body; 
    var cek = `SELECT * FROM liked WHERE email like '${data.email}' and barangID = ${data.barangID}`
    conn.query(cek, (err, result)=>{
        if(result.length == 0){
            var query = `INSERT INTO liked VALUES ('','${data.barangID}','${data.email}')`

            conn.query(query, (err, result)=>{
                if(err){
                    resp.send(err);
                }else{
                    resp.send("data berhasil di tambahkan");
                }
            })
        }
    })
})

router.post('/deleteLike/:ID', (req, resp)=>{
    var ID = req.params.ID
    var cek = `delete FROM liked WHERE ID = ${ID}`
    conn.query(cek, (err, result)=>{
        if (err) {
            resp.status(500).send('Gagal menghapus');
        } else {
            resp.status(200).send('Barang berhasil menghapus');
        }
    })
})



module.exports = router;