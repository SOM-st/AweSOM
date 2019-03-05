Class {
	#name : #ParseCompleteClassTest,
	#superclass : #ParseClassTest,
	#category : #'AweSOM-Compiler-Test'
}

{ #category : #'as yet unclassified' }
ParseCompleteClassTest >> classObject [

	^ 'Object = nil (

    | class |
    
    "Accessing"
    class     = ( ^class )
    
    "Primitive size in bytes"
    objectSize = primitive
    
    "Comparing"
    =  other    = ( ^self == other )
    <> argument = ( ^(self = argument) not )
    == other    = primitive
    isNil       = ( ^false )
    " If you override =, you MUST override hashcode as well.  The rule
      obj1 = obj2   =>  obj1 hashcode = obj2 hashcode
      must be valid for all objects, or Hashtable will not work"
    
    "Converting"
    asString  = ( ^''instance of '' + (self class) )
    , element = ( ^(Vector new append: self) append: element )
    hashcode  = primitive
    
    "Evaluating"
    value     = ( ^self )
    
    "Printing"
    print     = ( self asString print )
    println   = ( self print. system printNewline )
    
    "Error handling"
    error: string = ( '''' println. (''ERROR: '' + string) println. system exit )
    
    "Abstract method support"
    subclassResponsibility = (
        self error: ''This method is abstract and should be overridden''
    )
    
    "Error recovering"
    doesNotUnderstand: selector arguments: arguments = (
        self error:
            (''Method '' + selector + '' not found in class '' + class name)
    )
    
    escapedBlock: block = (
        self error: ''Block has escaped and cannot be executed''
    )
    
    unknownGlobal: name = ( ^system resolve: name )
    
    "Reflection"
    respondsTo: aSymbol = (
        (self class hasMethod: aSymbol)
            ifTrue:  [ ^true ]
            ifFalse: [ | cls |
                cls := self class superclass.
                [ cls isNil ] whileFalse: [
                    (cls hasMethod: aSymbol)
                        ifTrue:  [ ^true ]
                        ifFalse: [ cls := cls superclass ] ].
                ^ false ]
    )
    
)'
]

{ #category : #'as yet unclassified' }
ParseCompleteClassTest >> classSystem [

	^ '"

$Id: System.som 226 2008-04-21 12:45:01Z michael.haupt $

Copyright (c) 2001-2007 see AUTHORS file

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the ''Software''), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ''AS IS'', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
"

System = (

    "Accessing"
    global: name            = primitive
    global: name put: value = primitive
    
    "Initializing"
    initialize: arguments = (
        | application |
        
        "Make sure we have got at least one argument"
        (arguments length < 1) ifTrue: [ ''No class specified'' println. ^nil ].
        
        "Load the class with the specified name, create an instance of it, and
         run it. If there is more than only the class given on the command line,
         and the class has a method #run:, the arguments array is passed to it,
         otherwise, #run is sent."
        application := (self resolve: (arguments at: 1) asSymbol) new.
        
        (arguments length > 1) && (application class hasMethod: #run:)
            ifTrue:  [ application run: arguments ]
            ifFalse: [ application run ]
    )
    
    "Loading and resolving"
    load:    symbol = primitive
    resolve: symbol = (
        | class current_class |
        
        "Check if we''ve already got the global"
        (self global: symbol) == nil ifFalse: [ ^self global: symbol ].
        
        "Try loading the class"
        class := self load: symbol.
        (class == nil) ifFalse: [
            "Put class and its super-classes into global dictionary. We can stop
             as soon as we find a super-class in the globals dictionary because
             in this case, all its super-classes must have been added to the
             dictionary earlier"
             current_class := class.
             [ (self global: (current_class name)) == nil ] whileTrue: [
                self global: (current_class name) put: current_class.
                current_class := current_class superclass. ].
            ^class ].
        self error: ''Unable to resolve '' + symbol
    )
    
    "Exiting"
    exit: error  = primitive  
    exit         = ( self exit: 0 )
    
    "Printing"
    printString: string = primitive
    printNewline        = primitive
    
    "Time"
    time = primitive
    
    "Force Garbage Collection"
    fullGC = primitive
    
    ----------------------------------
    
    "Allocation"
    new = ( self error: ''The system object is singular'' )
    
)
'
]

{ #category : #tests }
ParseCompleteClassTest >> test01parseSystem [

	self setUpParser: self classSystem.
	parser start.
	parser cgenc.
	"self halt."
]

{ #category : #tests }
ParseCompleteClassTest >> test02parseObject [

	self setUpParser: self classObject.
	parser start.
	parser cgenc.
	"self halt."
]
