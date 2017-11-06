WORKSPACE=$(shell pwd)
CONTRACT_DIR=$(WORKSPACE)/contracts
SOURCES=$(shell find -L ./contracts -name *.sol)

.PHONY: default all shirley

default: pluto
all: pluto
shirley: pluto

define rename_file
	cp build/$(1).abi build/$(2).abi
	cp build/$(1).bin build/$(2).bin
endef

define web3j_build
	web3j solidity generate build/$(1).bin build/$(1).abi -o build/web3j -p network.pluto.alfred.contracts
endef

library:
	solcjs --allow-paths contracts \
		contracts/zeppelin-solidity/math/SafeMath.sol \
		--abi --bin --optimize -o build

pluto: clean
	solcjs --allow-paths contracts \
		$(SOURCES) \
		--abi --bin --optimize -o build

	$(call rename_file,contracts_pluto_Pluto_sol_Pluto,Pluto)
	$(call rename_file,contracts_pluto_PlutoWallet_sol_PlutoWallet,PlutoWallet)
	$(call rename_file,contracts_pluto_token_PLTToken_sol_PLTToken,PLTToken)

	$(MAKE) web3j

web3j:
	$(call web3j_build,Pluto)
	$(call web3j_build,PlutoWallet)
	$(call web3j_build,PLTToken)

deploy:
	node scripts/deploy.js

clean:
	rm -rf $(WORKSPACE)/build
	rm -rf $(WORKSPACE)/web3j
