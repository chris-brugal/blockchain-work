from brownie import accounts, config, SimpleStorage


def deploy_simple_storage():
    account = accounts[0]
    # account = accounts.load("dev")
    # account = accounts.add(config["wallets"]["from_key"])

    # instead of web3 create, sign, and send txn
    simple_storage = SimpleStorage.deploy({"from": account})

    # transaction vs call
    stored_value = simple_storage.retrieve()
    print(stored_value)


def main():
    deploy_simple_storage()
