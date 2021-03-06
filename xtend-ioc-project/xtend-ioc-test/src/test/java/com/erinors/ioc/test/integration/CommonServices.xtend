/*
 * #%L
 * xtend-ioc-test
 * %%
 * Copyright (C) 2015-2016 Norbert Sándor
 * %%
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * #L%
 */
package com.erinors.ioc.test.integration

import com.erinors.ioc.shared.api.Component

interface HelloService {
	def String sayHello(String name)
}

@Component
class HelloServiceImpl implements HelloService {
	override sayHello(String name) {
		'''Hello «name»!'''
	}
}

interface GoodbyeService {
	def String sayGoodbye(String name)
}

@Component
class GoodbyeServiceImpl implements GoodbyeService {
	override sayGoodbye(String name) {
		'''Goodbye «name»!'''
	}
}
