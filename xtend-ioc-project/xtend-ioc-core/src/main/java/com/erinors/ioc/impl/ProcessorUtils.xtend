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

import com.erinors.ioc.shared.api.Module
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.AnnotationTarget
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Declaration
import org.eclipse.xtend.lib.macro.declaration.Element
import org.eclipse.xtend.lib.macro.declaration.EnumerationValueDeclaration
import org.eclipse.xtend.lib.macro.declaration.ExecutableDeclaration
import org.eclipse.xtend.lib.macro.declaration.InterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.MemberDeclaration
import org.eclipse.xtend.lib.macro.declaration.ParameterDeclaration
import org.eclipse.xtend.lib.macro.declaration.Type
import org.eclipse.xtend.lib.macro.declaration.TypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.services.Problem
import org.eclipse.xtend.lib.macro.services.Tracability

@Data
class ProcessingMessage
{
	Problem.Severity severity

	Element element

	String message
}

class ProcessorUtils
{
	def static hasAnnotation(AnnotationTarget annotationTarget, String annotationQualifiedName)
	{
		annotationTarget.getAnnotation(annotationQualifiedName) !== null
	}

	def static getAnnotation(AnnotationTarget annotationTarget, String annotationQualifiedName)
	{
		annotationTarget.annotations.findFirst[annotationTypeDeclaration.qualifiedName == annotationQualifiedName]
	}

	def static hasAnnotation(AnnotationTarget annotationTarget, Class<?> annotationClass)
	{
		annotationTarget.getAnnotation(annotationClass) !== null
	}

	def static getAnnotation(AnnotationTarget annotationTarget, Class<?> annotationClass)
	{
		annotationTarget.getAnnotation(annotationClass.name)
	}

	// TODO nem jó helyen
	def static isSingletonModule(InterfaceDeclaration moduleDeclaration, extension TransformationContext context)
	{
		val moduleAnnotation = moduleDeclaration.getAnnotation(Module.findTypeGlobally)

		if (moduleAnnotation === null)
		{
			throw new IllegalStateException('''Not a module declaration: «moduleDeclaration.qualifiedName»''')
		}

		moduleAnnotation.getBooleanValue("singleton")
	}

	def static findDefaultConstructor(ClassDeclaration classDeclaration, extension Tracability tracability)
	{
		val constructor = classDeclaration.declaredConstructors.filter[parameters.empty].head
		if (constructor !== null && !constructor.isThePrimaryGeneratedJavaElement)
			constructor
		else
			null
	}

	def static boolean hasAnnotation(AnnotationTarget annotationTarget, Type annotationType)
	{
		annotationTarget.getAnnotation(annotationType) !== null
	}

	def static AnnotationReference getAnnotation(AnnotationTarget annotationTarget, Type annotationType)
	{
		annotationTarget.findAnnotation(annotationType)
	}

	def static String getPackageName(Type type)
	{
		val qualifiedName = type.qualifiedName
		if (qualifiedName.contains("."))
			qualifiedName.substring(0, type.qualifiedName.lastIndexOf('.'))
		else
			""
	}

	def static toDisplayName(Element element)
	{
		switch (element)
		{
			Declaration: element.asString
			default: element.toString
		}
	}

	def static String asString(Element element)
	{
		switch (element)
		{
			TypeDeclaration:
				element.qualifiedName
			ExecutableDeclaration:
			'''«element.declaringType.simpleName».«element.simpleName»()'''
			MemberDeclaration:
			'''«element.declaringType.simpleName».«element.simpleName»'''
			ParameterDeclaration:
			'''parameter '«element.simpleName»' of «element.type.simpleName»'''
			default:
				element.toString
		}
	}

	def static hasSuperclass(TypeReference typeReference)
	{
		typeReference.superclass !== null && typeReference.superclass.name != Object.name
	}

	def static getSuperclass(TypeReference typeReference)
	{
		typeReference.declaredSuperTypes.findFirst[type instanceof ClassDeclaration]
	}

	def static generateRandomMethodName(TypeDeclaration typeDeclaration)
	{
		return generateRandomName(typeDeclaration.declaredMethods)
	}

	def static generateRandomFieldName(TypeDeclaration typeDeclaration)
	{
		return generateRandomName(typeDeclaration.declaredFields)
	}

	def private static generateRandomName(Iterable<? extends Declaration> declarations)
	{
		var String randomName
		do
		{
			randomName = "_" + Long.toHexString(Double.doubleToLongBits(Math.random()));
		}
		while (declarations.map[simpleName].toSet.contains(randomName))

		return randomName
	}

	def static valueToSourceCode(Object value)
	{
		if (value === null)
		{
			"null"
		}
		else
		{
			// TODO support arrays
			// TODO raise error on annotations
			switch (value)
			{
				String:
				'''"«value»"'''
				Number:
					value.toString
				EnumerationValueDeclaration:
				'''«value.declaringType.qualifiedName».«value.simpleName»'''
				TypeReference:
					value.name
				default:
					throw new AssertionError('''Unsupported value: «value»''')
			}
		}
	}

	def static hasSuperclass(ClassDeclaration classDeclaration)
	{
		classDeclaration.extendedClass !== null && classDeclaration.extendedClass.type.qualifiedName != Object.name
	}
}
