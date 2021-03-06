/*
 * #%L
 * xtend-ioc-core
 * %%
 * Copyright (C) 2015-2016 Norbert Sándor
 * %%
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * #L%
 */
package com.erinors.ioc.impl

import java.lang.annotation.Annotation
import java.util.List
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtend.lib.macro.AbstractInterfaceProcessor
import org.eclipse.xtend.lib.macro.CodeGenerationContext
import org.eclipse.xtend.lib.macro.CodeGenerationParticipant
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.RegisterGlobalsParticipant
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.ValidationContext
import org.eclipse.xtend.lib.macro.ValidationParticipant
import org.eclipse.xtend.lib.macro.declaration.Declaration
import org.eclipse.xtend.lib.macro.declaration.InterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableInterfaceDeclaration
import org.eclipse.xtend.lib.macro.services.ProblemSupport

import static extension com.erinors.ioc.shared.util.ListUtils.*

@FinalFieldsConstructor
class AbstractSafeInterfaceProcessor implements RegisterGlobalsParticipant<Declaration>, TransformationParticipant<MutableDeclaration>, CodeGenerationParticipant<Declaration>, ValidationParticipant<Declaration>
{
	val AbstractInterfaceProcessor delegate

	val Class<? extends Annotation> annotationClass

	val String errorCode

	override doRegisterGlobals(List<? extends Declaration> annotatedSourceElements,
		extension RegisterGlobalsContext context)
	{
		val validSourceElements = annotatedSourceElements.removeNullElements
		if (check(validSourceElements, null))
		{
			delegate.doRegisterGlobals(validSourceElements as List<? extends InterfaceDeclaration>, context)
		}
	}

	override doTransform(List<? extends MutableDeclaration> annotatedTargetElements,
		extension TransformationContext context)
	{
		val validTargetElements = annotatedTargetElements.removeNullElements
		if (check(validTargetElements, context))
		{
			delegate.doTransform(validTargetElements as List<? extends MutableInterfaceDeclaration>, context)
		}
	}

	override doGenerateCode(List<? extends Declaration> annotatedSourceElements,
		extension CodeGenerationContext context)
	{
		val validSourceElements = annotatedSourceElements.removeNullElements
		if (check(validSourceElements, null))
		{
			delegate.doGenerateCode(validSourceElements as List<? extends InterfaceDeclaration>, context)
		}
	}

	override doValidate(List<? extends Declaration> annotatedTargetElements, extension ValidationContext context)
	{
		val validTargetElements = annotatedTargetElements.removeNullElements
		if (check(validTargetElements, null))
		{
			delegate.doValidate(validTargetElements as List<? extends InterfaceDeclaration>, context)
		}
	}

	def private check(List<? extends Declaration> declarations, ProblemSupport problemSupport)
	{
		val invalidDeclarations = declarations.filter[!(it instanceof InterfaceDeclaration)]
		invalidDeclarations.forEach [
			if (problemSupport !== null)
			{
				if (annotationClass !== null)
				{
					problemSupport.addError(
						it, '''@«annotationClass.simpleName» is supported only for interface declarations.«IF errorCode != null» [«errorCode»]«ENDIF»''')
				}
				else
				{
					problemSupport.addError(
						it, '''Annotation is supported only for interface declarations.«IF errorCode != null» [«errorCode»]«ENDIF»''')
				}
			}
		]
		return invalidDeclarations.empty
	}
}
