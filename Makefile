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

pluto: clean
	solcjs --allow-paths contracts \
		contracts/lib/ownership/Ownable.sol \
		contracts/lib/math/SafeMath.sol \
		contracts/lib/lifecycle/Pausable.sol \
		contracts/lib/token/ERC20.sol \
		contracts/lib/token/ERC20Basic.sol \
		contracts/lib/token/BasicToken.sol \
		contracts/lib/token/StandardToken.sol \
		contracts/lib/token/MintableToken.sol \
		contracts/lib/token/PausableToken.sol \
		contracts/pluto/PlutoWallet.sol \
		contracts/pluto/Pluto.sol \
		contracts/pluto/token/PLTToken.sol --abi --bin --optimize -o build

clean:
	rm -rf $(WORKSPACE)/build
