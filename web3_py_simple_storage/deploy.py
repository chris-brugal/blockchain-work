from solcx import compile_standard, install_solc
import json
from web3 import Web3
import os
from dotenv import load_dotenv

load_dotenv()

with open("./SimpleStorage.sol", "r") as file:
    simple_storage_file = file.read()
print("Installing...")

# compile solidity:
install_solc("0.6.0")
compiled_sol = compile_standard(
    {
        "language": "Solidity",
        "sources": {"SimpleStorage.sol": {"content": simple_storage_file}},
        "settings": {
            "outputSelection": {
                "*": {"*": ["abi", "metadata", "evm.bytecode", "evm.sourceMap"]}
            }
        },
    },
    solc_version="0.6.0",
)

with open("compiled_code.json", "w") as file:
    json.dump(compiled_sol, file)


# to deploy to chain need ABI and bytecode
# get bytecode
bytecode = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["evm"][
    "bytecode"
]["object"]

# get abi
abi = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["abi"]

# for connecting to rinkeby (could use ganache for local)
w3 = Web3(
    Web3.HTTPProvider("https://rinkeby.infura.io/v3/8fc8fc66fbf94847af11f8a8f3532003")
)
chain_id = 4
my_address = "0x9debD84221a3A118E8F14f2F2854204172d8b7B3"
private_key = os.getenv("PRIVATE_KEY")

# create the contract in pyhton
SimpleStorage = w3.eth.contract(abi=abi, bytecode=bytecode)

# get the latest transaction # (nonce)
nonce = w3.eth.getTransactionCount(my_address)

# build transaction
transaction = SimpleStorage.constructor().buildTransaction(
    {
        "gasPrice": w3.eth.gas_price,
        "chainId": chain_id,
        "from": my_address,
        "nonce": nonce,
    }
)

# sign transaction
signed_txn = w3.eth.account.sign_transaction(transaction, private_key=private_key)
print("Deploying Contract!")

# send transaction
tx_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
# Wait for the transaction to be mined, and get the transaction receipt
print("Waiting for transaction to finish...")
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)


# work with contract
# need contract address
# need contract ABI
simple_storage = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)
print(f"Initial Stored Value {simple_storage.functions.retrieve().call()}")

# call -> simulate making the call and gettnig a return value
# transact -> actually make a state change

# make a state changing contract to update fav number
# print(simple_storage.functions.retrieve().call())
# build
store_transaction = simple_storage.functions.store(15).buildTransaction(
    {
        "gasPrice": w3.eth.gas_price,
        "chainId": chain_id,
        "from": my_address,
        "nonce": nonce + 1,
    }
)
# sign
signed_store_txn = w3.eth.account.sign_transaction(
    store_transaction, private_key=private_key
)
# send
send_store_tx = w3.eth.send_raw_transaction(signed_store_txn.rawTransaction)
print("Updating stored Value...")
tx_receipt = w3.eth.wait_for_transaction_receipt(send_store_tx)
print(simple_storage.functions.retrieve().call())
