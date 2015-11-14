package com.erinors.ioc.impl

import com.erinors.ioc.shared.api.Interceptor
import com.erinors.ioc.shared.api.InvocationPointConfiguration
import java.lang.annotation.Annotation
import org.eclipse.xtend.lib.annotations.AccessorsProcessor
import org.eclipse.xtend.lib.macro.AbstractAnnotationTypeProcessor
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableAnnotationTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

class InterceptorProcessor<T extends Annotation> extends AbstractSafeAnnotationTypeProcessor
{
	new()
	{
		super(new InterceptorProcessorImplementation, Interceptor, "TODO") // TODO error code
	}
}

package class InterceptorProcessorImplementation<T extends Annotation> extends AbstractAnnotationTypeProcessor
{
	override doRegisterGlobals(AnnotationTypeDeclaration annotatedAnnotationType,
		extension RegisterGlobalsContext context)
	{
		registerClass(InterceptorUtils.invocationPointConfigurationClassName(annotatedAnnotationType))
	}

	override doTransform(MutableAnnotationTypeDeclaration annotatedAnnotationType,
		extension TransformationContext context)
	{
		try
		{
			val interceptorDefinitionModel = new InterceptorDefinitionModelBuilder(context).build(
				annotatedAnnotationType)

			val generatedClass = findClass(interceptorDefinitionModel.invocationPointConfigurationClassName)
			generatedClass.implementedInterfaces = #[InvocationPointConfiguration.newTypeReference]

			val accessorsUtils = new AccessorsProcessor.Util(context)
			interceptorDefinitionModel.parameters.forEach [ interceptorParameter |
				val field = generatedClass.addField(interceptorParameter.name, [
					type = interceptorParameter.type.getApiType(context)
					final = true
				])

				accessorsUtils.addGetter(field, Visibility.PUBLIC)
			]

			// TODO does not work
			// val constructorUtils = new FinalFieldsConstructorProcessor.Util(context)
			// constructorUtils.addFinalFieldsConstructor(generatedClass)
			generatedClass.addConstructor [ constructor |
				interceptorDefinitionModel.parameters.forEach [ interceptorParameter |
					constructor.addParameter(interceptorParameter.name, interceptorParameter.type.getApiType(context))
				]
				constructor.body = '''
					«FOR parameter : interceptorDefinitionModel.parameters»
						this.«parameter.name» = «parameter.name»;
					«ENDFOR»
				'''
			]
		}
		catch (Exception e)
		{
			ProcessorUtils.handleExceptions(e, context, annotatedAnnotationType)
		}
	}
}