# AweSOM - The Simple Object Machine Smalltalk implemented in Smalltalk

## Introduction

[SOM] is a minimal Smalltalk dialect used to teach VM construction at the [Hasso
Plattner Institute][HPI]. It was originally built at the University of Århus
(Denmark) where it was used for teaching and as the foundation for [Resilient
Smalltalk][RS].

This repository contains the Smalltalk-based implementation of SOM, including
SOM's standard library and a number of examples. In addition to AweSOM, other
implementations exist for Java (SOM), C (CSOM), C++ (SOM++), and Python
(PySOM). Please see the [main project page][SOM] for links to other VM
implementations.

A simple Hello World looks like:

```Smalltalk
Hello = (
  run = (
    'Hello World!' println.
  )
)
```

Obtaining and Running TruffleSOM
--------------------------------

To checkout the code:

    git clone https://github.com/SOM-st/AweSOM.git

Then, build AweSOM for the use with [Pharo]:

    make

This will also execute the tests, which could also be done manually:

    ./som.sh -cp Smalltalk TestSuite/TestHarness.som
   
A simple Hello World program is executed with:

    ./som.sh -cp Smalltalk Examples/Hello.som

Information on previous authors are included in the AUTHORS.md file. This code
is distributed under the MIT License. Please see the LICENSE.md file for
details.


Build Status
------------

Thanks to Travis CI, all commits of this repository are tested.
The current build status is: [![Build Status](https://api.travis-ci.com/SOM-st/AweSOM.png?branch=master)](https://travis-ci.com/SOM-st/AweSOM)

 [SOM]:    https://som-st.github.io/
 [HPI]:    http://www.hpi.uni-potsdam.de/hirschfeld/projects/som/
 [RS]:     http://dx.doi.org/10.1016/j.cl.2005.02.003
 [Pharo]:  https://pharo.org/