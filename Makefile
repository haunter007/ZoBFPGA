.PHONY: python cpp-build cpp compare hls-csim hls-csim-step hls-cosim hls-cosim-step

python:
	python3 src/python/zonotope.py

cpp-build:
	$(MAKE) -C src/cpp

cpp: cpp-build
	$(MAKE) -C src/cpp run

compare:
	python3 src/compare/plot_comparison.py

hls-csim:
	$(MAKE) -C src/hls csim

hls-csim-step:
	$(MAKE) -C src/hls csim-step

hls-cosim:
	$(MAKE) -C src/hls cosim

hls-cosim-step:
	$(MAKE) -C src/hls cosim-step
