.PHONY: deploy
deploy:
	@echo "ZP_COMMIT_DATE_EPOCH=$${ZP_COMMIT_DATE_EPOCH}" > env_dump.txt
	@echo "ZP_COMMIT_SHA=$${ZP_COMMIT_SHA}" >> env_dump.txt
	@echo "ZP_COMMIT_SUBJECT=$${ZP_COMMIT_SUBJECT}" >> env_dump.txt
	@echo "ZP_COMMIT_AUTHOR_NAME=$${ZP_COMMIT_AUTHOR_NAME}" >> env_dump.txt
	@echo "ZP_COMMIT_AUTHOR_EMAIL=$${ZP_COMMIT_AUTHOR_EMAIL}" >> env_dump.txt
	@echo "ZP_COMMIT_COMMITTER_NAME=$${ZP_COMMIT_COMMITTER_NAME}" >> env_dump.txt
	@echo "ZP_COMMIT_COMMITTER_EMAIL=$${ZP_COMMIT_COMMITTER_EMAIL}" >> env_dump.txt
	@echo "ZP_BRANCH=$${ZP_BRANCH}" >> env_dump.txt
	@echo "ZP_ORIGIN_URL=$${ZP_ORIGIN_URL}" >> env_dump.txt
	@echo "SOURCE_DATE_EPOCH=$${ZP_COMMIT_DATE_EPOCH}" >> env_dump.txt
