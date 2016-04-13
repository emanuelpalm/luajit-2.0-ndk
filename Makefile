ENV_CONF = conf/env.conf

default: generate

setup: ${ENV_CONF}

${ENV_CONF}:
	@$(shell ./bash/setup.sh)

generate: ${ENV_CONF}
	@$(shell ./bash/generate.sh $<)

clean:
	$(foreach F,$(wildcard ${ENV_CONF}),${RM} $F)
	$(foreach F,$(wildcard make/*.mk),${RM} $F;)

.PHONY: default setup generate clean
