var express = require("express");
var router = express.Router();
var conn = require('./conn');
const multer = require('multer');

const path = require('path');

router.get('/', (req, resp) => {
    var query = "SELECT namaBarang, harga, deskripsi, ID, gambar FROM barang";
    conn.query(query, (err, results) => {
        // if (err) {
        //     console.error(err);
        //     return resp.status(500).json({ message: "Internal Server Error" });
        // } else {
        //     if (results.length === 0) {
        //         console.log("No data found");
        //         // return resp.status(404).json({ message: "No data found" });
        //     } else {
        //         resp.json(results)
        //     }
        // }
        if (err) {
            throw err;
          }
          resp.json({ 
            data: results // Kirim data sebagai response
          });
    });
});

router.get('/:ID', (req, resp) => {
  const ID = req.params.ID;
  var query = `SELECT namaBarang, harga, deskripsi, gambar, warna, material, ID FROM barang WHERE ID = ${ID}`;
  conn.query(query, (err, results) => {
      // if (err) {
      //     console.error(err);
      //     return resp.status(500).json({ message: "Internal Server Error" });
      // } else {
      //     if (results.length === 0) {
      //         console.log("No data found");
      //         // return resp.status(404).json({ message: "No data found" });
      //     } else {
      //         resp.json(results)
      //     }
      // }
      if (err) {
          throw err;
        }
        resp.json({ 
          data: results // Kirim data sebagai response
        });
  });
});

router.get('/images/:filename', (req, res) => {
  const filename = req.params.filename;
  const imagePath = path.join(__dirname, './uploads', filename); // Ubah 'uploads' sesuai dengan struktur folder Anda

  // Kirim file gambar sebagai respons
  res.sendFile(imagePath);
  // console.log(imagePath);
});

module.exports = router;
