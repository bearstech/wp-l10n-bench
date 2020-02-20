# Copyright (C) 2020 Bearstech - https://bearstech.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

default: build run

build:
	docker build -q -t bearstech/wpbench .

run:
	docker run --rm -ti -e WPLANG="$(WPLANG)" bearstech/wpbench

debug:
	docker run --rm -ti -e WPLANG="$(WPLANG)" bearstech/wpbench bash
