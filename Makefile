WORKSPACE=$(shell pwd)
CONTRACT_DIR=$(WORKSPACE)/contracts

.PHONY: default all shirley

default: pluto
all: pluto
shirley: pluto

define solc_build
	if [ ! -d "$(WORKSPACE)/build" ]; then mkdir -p $(WORKSPACE)/build; fi
	sed -e 's|$${__WORKSPACE__}|'"$(WORKSPACE)"'|g' $(WORKSPACE)/$(1) | solc --allow-paths $(WORKSPACE) --standard-json > $(WORKSPACE)/$(1)
endef

library:
	solcjs --allow-paths contracts \
		contracts/zeppelin-solidity/math/SafeMath.sol \
		--abi --bin --optimize -o build

pluto: clean
	solcjs --allow-paths contracts \
		contracts/zeppelin-solidity/ownership/Ownable.sol \
		contracts/zeppelin-solidity/math/SafeMath.sol \
		contracts/zeppelin-solidity/lifecycle/Pausable.sol \
		contracts/zeppelin-solidity/token/ERC20.sol \
		contracts/zeppelin-solidity/token/ERC20Basic.sol \
		contracts/zeppelin-solidity/token/BasicToken.sol \
		contracts/zeppelin-solidity/token/StandardToken.sol \
		contracts/zeppelin-solidity/token/MintableToken.sol \
		contracts/zeppelin-solidity/token/PausableToken.sol \
		contracts/pluto/token/PLTToken.sol \
		contracts/pluto/PlutoWallet.sol \
		contracts/pluto/Pluto.sol \
		--abi --bin --optimize -o build

clean:
	rm -rf $(WORKSPACE)/build
