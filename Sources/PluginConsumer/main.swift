// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.
//
// In jurisdictions that recognize copyright laws, the author or authors
// of this software dedicate any and all copyright interest in the
// software to the public domain. We make this dedication for the benefit
// of the public at large and to the detriment of our heirs and
// successors. We intend this dedication to be an overt act of
// relinquishment in perpetuity of all present and future rights to this
// software under copyright law.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
// OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// For more information, please refer to <http://unlicense.org>

// Created by Jan "Lope" Kosa
// on 2017/04/10

import Foundation
import PluginInterface

class Consumer: PluginConsumerInterface {

	func sayHiBack() {
		print("Hi back to you, says Consumer")
	}
}

// template for function inside library that will return our plugin class
typealias InitFunction = @convention(c) () -> UnsafeMutableRawPointer

func loadPlugin() {
	
	let pathToPlugin = "path/to/PluginConsumer/Plugins/libPluginImplementation.dylib"

	let openRes = dlopen(pathToPlugin, RTLD_NOW|RTLD_LOCAL)
	if openRes != nil {
		defer {
			dlclose(openRes)
		}

		let symbolName = "createPlugin"
		let sym = dlsym(openRes, symbolName)

		if sym != nil {
			let f: InitFunction = unsafeBitCast(sym, to: InitFunction.self)
			let pluginPointer = f()
			let plugin = Unmanaged<PluginInterface>.fromOpaque(pluginPointer).takeRetainedValue()
			plugin.consumer = Consumer()
			plugin.sayHi()
		} else {
			print("Error loading \(pathToPlugin). \n\tSymbol \(symbolName) not found.")
		}
	} else {
		if let err = dlerror() {
			let errMsg = String(format: "%s", err)
			print("error opening lib:", errMsg)
		} else {
			print("error opening lib: unknown error")
		}
	}

}

// call function that will load our plugin
loadPlugin()
