const express = require("express");
const multer = require('multer');
const router = express.Router();
const conn = require('./conn');
const path = require('path');
const bodyParser = require('body-parser');


const storage = multer.diskStorage({
  destination: (req, file, cb) =>{
    cb(null, "./router/uploads") // Ubah path penyimpanan sesuai struktur folder Anda
  },
  filename: (req, file, cb)=>{
    cb(null, Date.now().toString() + file.originalname ) // Menggunakan nama file asli dan menambahkan timestamp
  }
});

const upload = multer({ storage: storage });


router.post('/addbarang', upload.single('image'), (req, res) => {
  const data = req.body;
  const fileName = req.file.filename;
  console.log(data);

  // Menggunakan placeholder untuk menghindari SQL injection
  
  var query = `INSERT INTO barang VALUES ("","${data.namaBarang}","${data.deskripsi}",${data.harga},"${data.warna}","${data.material}","${data.email}","${fileName}")`;
  // const query = `INSERT INTO barang (namaBarang, deskripsi, harga, warna, material, email, namaFile) VALUES (?, ?, ?, ?, ?, ?, ?)`;
  // const values = [data.namaBarang, data.deskripsi, data.harga, data.warna, data.material, data.email, file.filename];

  conn.query(query,(err, result) => {
    if (err) {
      res.status(500).send(err);
    } else {
      res.status(200).send("Data berhasil ditambahkan");
    }
  });
});

// router.use(upload.array());
router.post('/updateBarang', (req, res) => {
  const data = req.body;
  console.log(data)
  // Menggunakan placeholder untuk menghindari SQL injection
  
  var query = `UPDATE barang SET namaBarang = "${data.namaBarang}", deskripsi = "${data.deskripsi}", harga = ${data.harga}, warna = "${data.warna}", material = "${data.material}" WHERE ID = ${data.ID}`;
  // const query = `INSERT INTO barang (namaBarang, deskripsi, harga, warna, material, email, namaFile) VALUES (?, ?, ?, ?, ?, ?, ?)`;
  // const values = [data.namaBarang, data.deskripsi, data.harga, data.warna, data.material, data.email, file.filename];

  conn.query(query,(err, result) => {
    if (err) {
      res.status(500).send(err);
    } else {
      res.status(200).send("Data berhasil ditambahkan");
    }
  });
});

router.post('/delete', (req, res) => {
  const data = req.body;
  var query = `DELETE FROM barang WHERE ID = ${data.Id_barang}`;
  var query2 = `SELECT * FROM liked WHERE barangID = ${data.Id_barang}`;
  var query3 = `SELECT * FROM cart WHERE barangID = ${data.Id_barang}`;

  conn.query(query, (err, result) => {
    if (err) {
      res.status(500).send(err);
    } else {
      conn.query(query2, (err, likedResult) => {
        if (err) {
          res.status(500).send(err);
        } else if (likedResult.length !== 0) {
          var query4 = `DELETE FROM liked WHERE barangID = ${data.Id_barang}`;
          conn.query(query4, (err, result) => {
            if (err) {
              res.status(500).send(err);
            } else {
              res.status(200).send('Barang dari database liked dihapus');
            }
          });
        }
      });

      conn.query(query3, (err, cartResult) => {
        if (err) {
          res.status(500).send(err);
        } else if (cartResult.length !== 0) {
          var query5 = `DELETE FROM cart WHERE barangID = ${data.Id_barang}`;
          conn.query(query5, (err, result) => {
            if (err) {
              res.status(500).send(err);
            } else {
              res.status(200).send('Barang dari database cart dihapus');
            }
          });
        } else {
          res.status(200).send('Data berhasil dihapus');
        }
      });
    }
  });
});


router.get('/:email', (req, resp) => {
  const email = req.params.email;
  var query = `SELECT * FROM barang where emailPublish = '${email}'`;
  conn.query(query, (err, results) => {
      if (err) {
          throw err;
        }
        resp.json({ 
          data: results // Kirim data sebagai response
        });
  });
});

router.get('/ambil/:barangID', (req, resp) => {
  const ID = req.params.barangID;
  var query = `SELECT * FROM barang where ID = ${ID}`;
  conn.query(query, (err, results) => {
      if (err) {
          throw err;
        }
        resp.json({ 
          data: results // Kirim data sebagai response
        });
  });
});

module.exports = router;
