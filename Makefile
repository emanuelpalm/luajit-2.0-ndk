ENV_CONF = conf/env.conf

default: generate

-include make/_all.mk

setup: ${ENV_CONF}

${ENV_CONF}:
	@$(shell ./bash/setup.sh)

generate: ${ENV_CONF}
	@$(shell ./bash/generate.sh $<)

clean:
	$(foreach F,$(wildcard ${ENV_CONF}),${RM} $F)
	$(foreach F,$(wildcard make/*.mk),${RM} $F;)
	$(foreach D,$(wildcard out),${RM} -R $D)

.PHONY: default setup generate clean
