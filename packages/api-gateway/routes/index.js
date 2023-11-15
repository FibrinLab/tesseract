const express = require("express");
const router = express.Router();

router.all("/:apiName", (req, res) => {
    console.log(req.params.apiName)
    res.send(req.params.apiName + "\n")
})

module.exports = router;