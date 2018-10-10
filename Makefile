build:
	vuepress build .

publish: build
	cd .vuepress/dist && \
		git init && \
		git add -A && \
		git commit -m "update docs" && \
		git push -f https://github.com/syaning/go-pkgs.git master:gh-pages

.SILENT: build publish