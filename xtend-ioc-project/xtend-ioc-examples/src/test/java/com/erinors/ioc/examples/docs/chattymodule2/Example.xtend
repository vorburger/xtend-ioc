/*
 * #%L
 * xtend-ioc-examples
 * %%
 * Copyright (C) 2015-2016 Norbert Sándor
 * %%
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * #L%
 */
package com.erinors.ioc.examples.docs.chattymodule2

import com.erinors.ioc.shared.api.Component
import com.erinors.ioc.shared.api.Inject
import com.erinors.ioc.shared.api.Module
import com.erinors.ioc.shared.api.Qualifier
import java.util.List
import org.junit.Test

import static org.junit.Assert.*

// tag::ChattyModule[]
interface HelloService {
	def String sayHello(String name)
}

@Qualifier
annotation English { // <1>
}

@Qualifier
annotation Hungarian { // <2>
}

@Component
@English // <3>
class EnglishHelloServiceImpl implements HelloService {
	override sayHello(String name) '''Hello «name»!'''
}

@Component
@Hungarian // <4>
class HungarianHelloServiceImpl implements HelloService {
	override sayHello(String name) '''Szia «name»!'''
}

@Component
class AnotherComponent {
	@Inject
	@English
	public HelloService englishHelloService // <5>
}

@Module(
	components=#[EnglishHelloServiceImpl, HungarianHelloServiceImpl, AnotherComponent]
)
interface ChattyModule {
	@English // <6>
	def HelloService englishHelloService()

	@Hungarian // <7>
	def HelloService hungarianHelloService()
	
	def List<? extends HelloService> helloServices()
	
	def AnotherComponent anotherComponent()
}

class ChattyModuleTest {
	@Test
	def void test() {
		val module = ChattyModule.Peer.initialize
		assertEquals("Hello Jeff!", module.englishHelloService.sayHello("Jeff"))
		assertEquals("Szia Jeff!", module.hungarianHelloService.sayHello("Jeff"))
		assertEquals(2, module.helloServices.size)
		assertTrue(
			module.englishHelloService ===
			module.anotherComponent.englishHelloService
		)
	}
}
// end::ChattyModule[]
