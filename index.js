const express = require("express");
const EventEmitter = require('events');
const { sql, poolPromise } = require("./dbConfig");
const { log } = require("console");

const orderEvent = new EventEmitter();

orderEvent.on('ordered',async (id)=>{
    let prom =  new Promise((resolve,reject)=>{
        setTimeout(async ()=>{
            const pool = await poolPromise;
            const result = await pool.request().query(`update orderstbl2 set Statuss = 'Successful' where id = ${id}`);
            resolve('Order is placed')
        },10000)
    })

    prom.then((resolve) => console.log(resolve))
})

const app = express();
app.use(express.json());

const port = 3000;


app.get("/orders", async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request().query("select * from orderstbl2");
        res.json(result.recordset);
    } catch (err) {
        res.status(500).send(err.message);
    }
});

app.post("/addOrders", async (req, res) => {
    try {
        const { OrderID, FoodItem, CustomerName } = req.body;
        let Status = 'pending'
        const pool = await poolPromise;
        await pool
            .request()
            .input("OrderID", OrderID)
            .input("foodItem",FoodItem)
            .input("CustomerName", CustomerName)
            .input("status",Status)
            .query("insert into orderstbl2 (id, foodItem, customerName, Statuss) values (@OrderID, @foodItem, @CustomerName, @status)");

        orderEvent.emit("ordered", OrderID);
         res.status(200).send("Your Order is in process. . ."); 
    } catch (err) {
        res.status(500).send(err.message);
    }
});

app.get("/orders/:OrderID", async (req, res) => {
    try {
        const { OrderID } = req.params;
        const pool = await poolPromise;
        const result = await pool.request()
            .input("OrderID", OrderID)
            .query("select * from Orders where OrderID = @OrderID");
        if (result.recordset.length > 0) {
            res.json(result.recordset);
        } else {
            res.status(404).send("Order Not Found");
        }
    } catch (err) {
        res.status(500).send(err.message);
    }
});

app.listen(port, () => {
    console.log(`Server Running on http://localhost:${port}`);

});