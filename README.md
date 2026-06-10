# MyPython

Python learning, scripting, automation, and technical-development repository.

## Purpose

This repository is a broad Python learning archive. It contains practice scripts, small exercises, lab-oriented examples, data-handling examples, networking examples, API work, and supporting files collected while learning Python and adjacent technical skills.

The repository is best understood as evidence of hands-on learning and technical development across several areas:

* Python programming fundamentals
* Scripting and automation
* User input and control flow
* Functions, modules, and exception handling
* Object-oriented programming
* Data structures and algorithms
* File handling and data parsing
* JSON, XML, HTML, and URL handling
* NumPy, SciPy, Matplotlib, and OpenCV practice
* Socket programming and basic networking
* Authorized cybersecurity lab and CTF-style exercises

This repository should not be interpreted as a polished production application or as paid software-development experience. It is a working learning archive.

## Cybersecurity

Confidentiality, Integrity, and Availability are the cornerstones of Cybersecurity. Unfortunately, every certification, every organziation, and every ego-maniacle gate-keepr in the industry thinks their definition is the aboslute pinnacle. They think this for some reason that is as yet completely mystical to me.  

The reality is that good definitions rarely give answers. Instead, these definitions should prompt questions on the part of the professional. In 1991, John McCumber, in his book "Assessing and managing security risk in IT systems : a structured methodology" gave us the most effective and useful definitions for the pillars. 

### Confidentiality

McCumber wrote:
> The primary consideration of confidentiality is not simply keeping information secret from everyone else; it is making it available only to those people who need it, when they need it, and under the appropriate circumstances. 

I would argue that McCumber gives birth to Zero-Trust in this definition. However, the failure of new professionals to look for the older magic means we failed to discover his ideas until twenty years later. McCumber doesn't seek to answer the question "What is confidentiality". Instead, he demands that professionals develop the necessary questions to determine if they have identified all the identies and attributes of a user, group, role, and service that would strongly indicate that a subjects request for access should be granted.

The use of specific words like "people", and "circumstances" may not have leant themselves to decomposing the idea of "people" and "circumstances" into users, groups, roles, services, and attributes. That might have been a bridge to far for "highly technical" types that rely on strict definitions and are often unable to make leaps of faith. Nevertheless, the foundation is there.

McCumber gives us the idea of multi-factor authentication as well as well as the extension into geolocation, geofencing, time, and a host of other attributes. For example, the IdAM engineer should consider putting certifications and expirations into their Active Directory or whichever solution they are using. Any system administrator requesting access to an administrator function should have their certification checks. If it's expired, they are denied access. This is a form of Attributed-based Access Control. 

We have had zero trust for some time, we just didn't recognize it.

### Integrity

Of integrity, McCumber wrote:
> how accurately and robustly the information reflects reality for a given application.

The question to be answered here is impossible to answer, but simple to state. To what degree must information presented represent reality, absent of perspective, to have integrity.

Philip K. Dick, the exceptionally gifted and prolific author lends his wisdom to this discussion identifing reality as
>that which, when you stop believing in it, doesn’t go away

No place can illustrate the ideas of integrity and reality more than the arena of Politics where two people can speak on the exact same topic use semantically and syntactically empty rhetoric, completely misrepresent reality and still incite the strongest of emotional reactions in tens of millions of people who have no idea what they are hearing other than "other guy bad". 

Integrity begs the receiver of information to think sufficiently critically to ask questions such as, 
- Does this information genuinly represent reality, or ground truth?
- What inconsistencies among the information might indicate decreased levels of integrity?
- Do I have sufficient understand of the topic to identify missing or incomplete information?
- To what degree is the source of information likely to have some bias?
- and oh so many more...

Whether people or data, integrity is the only true measure of quality.

### Availability

On this topic McCumber asserts that availability is > the ability of stored, transmitted, or processed information to be used for its intended purposes when required. 

In such a short statement, McCumber gave us incident response, backup, business continuity, and disaster recovery. 

## Current Repository Structure

The repository currently uses a mostly flat structure. Most Python files are stored directly in the repository root and are grouped by filename prefixes rather than by folders.

The current structure is approximately:

```text
MyPython/
├── *.py
├── *.pl
├── *.jl
├── *.txt
├── *.json
├── *.xml
├── *.zip
├── *.jpg
├── *.wav
├── *.code-workspace
└── resources/
    ├── *.png
    ├── *.jpg
    └── *.wav
```

A later reorganization may move files into topic-based folders, but this README intentionally documents the repository as it currently exists.

## Filename Conventions

Most files are currently organized by naming prefixes. These prefixes provide the best guide to the repository’s structure.

| Prefix / Pattern                                                  | General Meaning                                                                                                       |
| ----------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| `Intro_*`                                                         | Introductory Python syntax and basic exercises                                                                        |
| `BasicDataTypes_*`                                                | Beginner data-type and challenge exercises                                                                            |
| `Conditionals_*`                                                  | If/else logic, comparisons, and decision structures                                                                   |
| `Loops_*`, `WhileLoops.py`                                        | For loops, while loops, loop control, and pattern exercises                                                           |
| `Strings_*`                                                       | String formatting, validation, slicing, mutation, wrapping, and challenge exercises                                   |
| `Lists_*`, `LIsts_*`                                              | List operations, slicing, sorting, queues, stacks, and list comprehension                                             |
| `Tuple*`                                                          | Tuple behavior and tuple/set comparisons                                                                              |
| `Sets_*`                                                          | Set operations, membership, mutation, union, intersection, and difference                                             |
| `Dictionaries_*`, `Dictionary_*`                                  | Dictionary creation, modification, and key/value handling                                                             |
| `Functions_*`, `Function_*`                                       | Functions, recursion, lambda expressions, decorators, arguments, and scope                                            |
| `Modules_*`                                                       | Custom module creation and imports                                                                                    |
| `Exception_*`, `Exceptions_*`, `ErrorException*`                  | Error handling, exceptions, assertions, and validation                                                                |
| `Classes_*`, `med_11_*`                                           | Object-oriented programming, constructors, inheritance, polymorphism, iterators, generators, and operator overloading |
| `Arrays_*`, `Matrix_*`                                            | Arrays, matrix concepts, and multidimensional data                                                                    |
| `Data_*`                                                          | Data-structure concepts such as linked lists, trees, and turtle graphics                                              |
| `Searches_*`, `Sorts_*`                                           | Search and sorting algorithm practice                                                                                 |
| `Collections_*`, `collections_*`                                  | Python collections module practice                                                                                    |
| `Itertools_*`, `itertools_*`                                      | Itertools practice and combinatorics exercises                                                                        |
| `Regex_*`                                                         | Regular expression practice and validation exercises                                                                  |
| `Numpy_*`                                                         | NumPy array creation, manipulation, math, linear algebra, and visualization                                           |
| `SciPy_*`                                                         | SciPy practice, audio, FFT, clustering, signal generation, and linear algebra                                         |
| `Matplotlib_*`                                                    | Visualization practice                                                                                                |
| `OpenCV_*`                                                        | Image-processing practice                                                                                             |
| `HTML_*`, `XML_*`, `json_*`, `URL_*`                              | Parsing, structured data, and web/data handling                                                                       |
| `Socket_*`, `Sockets.py`                                          | TCP, UDP, threaded sockets, and socket programming                                                                    |
| `API_*`                                                           | API project material, including weather API work and API-key separation                                               |
| `Project_*`                                                       | Standalone project-style scripts                                                                                      |
| `CyStrt*`, `CTF_*`, `thm_*`                                       | CyberStart, CTF-style, and TryHackMe-related lab exercises                                                            |
| `resourceDevelopment_*`, `resrouceDevelopment_*`, `enumeration_*` | Security-lab scripting and learning artifacts                                                                         |
| `resources/*`                                                     | Supporting images, audio, and other assets used by scripts                                                            |

## Major Learning Areas

### Python Fundamentals

The repository includes many beginner and intermediate Python exercises covering:

* Printing and arithmetic
* Variables and data types
* User input
* Conditional logic
* Loops
* Lists, tuples, sets, and dictionaries
* String operations
* Formatting and validation
* Built-in functions

Representative files include:

```text
Intro_PrintFunction.py
Intro_ArithmeticOperators.py
Intro_IfElse.py
Intro_Loops.py
Conditionals_Basic.py
Conditionals_Comparisons.py
Loops_Basic.py
Loops_BasicFor.py
Loops_WhileBasic.py
Strings_Formatting.py
Strings_Validators.py
Lists_Basic.py
Sets_Introduction.py
Dictionaries_Basic.py
```

### Functions, Modules, and Exceptions

The repository includes practice with reusable functions, recursion, lambda expressions, decorators, keyword arguments, module creation, module imports, assertions, and exception handling.

Representative files include:

```text
Functions_Basic.py
Functions_ArguementTypes.py
Functions_KWARGS.py
Functions_Lambda.py
Function_Recursion.py
Functions_Decorators.py
Modules_CreateOwn.py
Modules_ImportMyFirstModule.py
Assertions.py
Exception_Handling.py
Exceptions_Handling.py
ErrorException.py
```

### Object-Oriented Programming

The repository includes a large number of class-based examples. These files document exposure to object-oriented programming concepts such as class creation, constructors, inheritance, inner classes, abstract classes, polymorphism, operator overloading, iterators, and generators.

Representative files include:

```text
Classes_Creation.py
Classes_Objects.py
Classes_Constructor.py
Classes_Inheritence.py
Classes_SubClasses.py
Classes_Polymorphism.py
Classes_OperatorOverloading.py
Classes_AbstractClasses.py
Classes_Iterator.py
Classes_Generators.py
Classes_OOP.py
```

### Data Structures and Algorithms

The repository includes foundational data-structure and algorithm examples.

Representative files include:

```text
Arrays_Basic.py
Arrays_CreateDuplicate.py
Arrays_CreatedByUserInput.py
Arrays_MultiDimension.py
Data_Linked.py
Data_Tree.py
Searches_Linear.py
Searches_Binary.py
Searches_BinaryV2.py
Sorts_Bubble.py
Sorts_Selection.py
Lists_Queue.py
Lists_Stack.py
```

### Data Handling, Parsing, and File Work

The repository includes examples for file handling, JSON import, XML parsing, HTML parsing, URL handling, and structured-data work.

Representative files include:

```text
Filehandling.py
FileHandling_ForLoops.py
FileHandling_UserInputs.py
Filehandling_Data.txt
json_ImportLogData.py
json_LogData.json
XML_Parse1.py
XML_Parse1.xml
XML_Parse2.py
XML_Tree.py
HTML_Parse1.py
HTML_Parse2.py
HTML_Parse3.py
URL_Encoding.py
URL_Slicing.py
```

### Scientific Python, Visualization, and Media

The repository includes practice with NumPy, SciPy, Matplotlib, OpenCV, image files, and audio files.

Representative files include:

```text
Numpy_Arrays.py
Numpy_ArrayMath.py
Numpy_LinearAlgebra.py
Numpy_Manipulations.py
Numpy_MeanVarStd.py
Numpy_Polynomials.py
Numpy_Visualization.py
SciPy_Audio.py
SciPy_Fft.py
SciPy_KMeans.py
SciPy_LinearAlgebra.py
SciPy_SignalGen.py
Matplotlib_3D.py
OpenCV_Intro.py
```

Supporting assets include files such as:

```text
resources/linked_list.png
resources/binary_tree.png
resources/landscape.jpg
resources/person.jpg
resources/sample.wav
sample.wav
cintaku.jpg
cintakucopy.jpg
```

### API and Automation Work

The repository includes an API-focused weather project and supporting files. This work demonstrates interaction with external services, user input, JSON-style data handling, basic validation, and separation of sensitive API material from main code.

Representative files include:

```text
API_Code.py
API_Weather.txt
API_Sensitive.py
```

Important note: any file that stores API keys, credentials, tokens, or sensitive configuration should be reviewed before public use. Sensitive material should be moved out of the repository and replaced with environment-variable examples or placeholder configuration files.

### Networking and Socket Programming

The repository includes socket programming examples and basic networking scripts.

Representative files include:

```text
Socket_TCP_Client.py
Socket_TCP_Server.py
Socket_UDP_Client.py
Socket_UDP_Server.py
Socket_Threads.py
Sockets.py
Project_PortScanner.py
```

These files should be treated as learning examples. Any scanning or network interaction should be performed only against systems where explicit authorization exists.

### Cybersecurity Lab and CTF-Style Exercises

The repository includes CyberStart, TryHackMe-related, CTF-style, and resource-development scripts. These appear to be learning artifacts associated with authorized lab environments, challenge platforms, or controlled exercises.

Representative files include:

```text
CyStrtForensicsL05C02.py
CyStrtHQL02C09.py
CyStrtMoonL02C02.py
CyStrtMoonL05C04.py
CTF_ZipfilePasswordL05C02.txt
CTF_ZipFileCracking.zip
thm_ResetToken.py
thm_rssslExploit.py
enumeration_WebAppUsernames.py
resourceDevelopment_bruteForce.py
resourceDevelopment_emailEnumeration.py
resourceDevelopment_exploitAutomation.py
resourceDevelopment_vulnScanner.py
resrouceDevelopment_basicRevShell.py
```

These files are retained as lab and learning artifacts only. They should not be used against real systems without explicit authorization. They should not be described as operational tools, production security tooling, or professional penetration-testing work unless separately supported by documented authorization and work history.

## Repository History and Cleanup Notes

This repository has had several stages:

1. Initial Python learning and exercise accumulation.
2. Additional Python files and supporting assets added over time.
3. CyberStart and CTF-style learning files added.
4. Additional missing files added.
5. Later cleanup removing at least one file identified as not owned.

The repository should continue to be reviewed for ownership, sensitive content, unnecessary binaries, generated files, and lab-only material before being presented as a polished portfolio repository.

## How to Interpret This Repository

This repository can support statements such as:

* Practiced Python scripting across a wide range of beginner and intermediate topics.
* Built small scripts using functions, loops, collections, file handling, APIs, and exception handling.
* Practiced object-oriented programming through class, constructor, inheritance, and polymorphism examples.
* Explored data structures, search algorithms, sorting algorithms, and scientific Python libraries.
* Practiced socket programming and basic networking concepts.
* Completed authorized cybersecurity lab and CTF-style scripting exercises.

This repository should not be used to claim:

* Paid software-development experience.
* Production deployment experience.
* Professional penetration-testing authorization.
* Mastery of every topic represented by a filename.
* Authorization to run security scripts outside controlled lab environments.
* Ownership of any third-party challenge prompt, copied exercise text, or external source material unless verified.

## Current Limitations

The repository is useful as a learning archive, but it is not yet organized as a polished portfolio project.

Current limitations include:

* Most files are stored at the root level.
* File names are descriptive but not consistently standardized.
* Some names contain typos, such as `Inheritence`, `Arguement`, `Fibbonacci`, `Numberals`, and `resrouceDevelopment`.
* Some files are exercises rather than original standalone projects.
* Some scripts may require local paths, local assets, API keys, or packages that are not documented.
* Some files may contain lab-specific logic or challenge-specific prompts.
* There is no current dependency file such as `requirements.txt`.
* There is no formal project index separating original work, course exercises, lab exercises, and supporting assets.

## Recommended Future Improvements

The repository should not be reorganized until a deliberate cleanup plan is approved. When that work begins, recommended improvements include:

1. Review files for ownership and remove material that should not be public.
2. Remove secrets, API keys, local credentials, and sensitive configuration.
3. Add a `.gitignore` for virtual environments, caches, local secrets, generated files, and local IDE artifacts.
4. Add `requirements.txt` or `pyproject.toml` after identifying actual dependencies.
5. Create a project index that distinguishes:

   * original scripts,
   * course exercises,
   * challenge/lab exercises,
   * supporting assets,
   * local-only files.
6. Move files into topic-based folders only after the current repository contents are fully reviewed.
7. Add short documentation to the strongest representative scripts.
8. Add safe-use notes for networking and cybersecurity-lab scripts.
9. Rename files carefully while preserving historical traceability.
10. Keep the repository description honest and evidence-based.

## Suggested Future Organization

This is not the current structure. It is a possible future structure after review:

```text
fundamentals/
functions-and-modules/
object-oriented-programming/
data-structures-and-algorithms/
data-science-and-parsing/
networking-and-automation/
cybersecurity-labs/
assets/
docs/
```

Until that reorganization occurs, this README documents the repository in its current root-heavy structure.

## Safe Use Notice

Some files involve networking, enumeration, archive/password exercises, exploit-related lab work, or reverse-shell concepts. These files are for authorized learning environments only.

Do not run security scripts against systems, services, networks, accounts, applications, or files unless you have explicit permission.

## Portfolio Use

For job-search or portfolio purposes, this repository is strongest as evidence of repeated hands-on Python exposure across many topics. It should be referenced carefully and specifically.

Good portfolio phrasing:

> Maintained a Python learning repository covering scripting fundamentals, object-oriented programming practice, data parsing, API interaction, socket programming, and authorized cybersecurity lab exercises.

Avoid overstated phrasing:

> Developed production Python applications.

> Built professional penetration-testing tools.

> Worked as a Python developer.

> Performed real-world exploitation or scanning.

## Summary

`MyPython` is a broad Python learning archive. Its value is the breadth of hands-on practice across Python fundamentals, scripting, data handling, scientific libraries, networking, and authorized lab-based cybersecurity exercises.

The repository should remain honest, safety-conscious, and clearly framed as technical learning evidence until it is later reviewed, cleaned, and reorganized into a more polished portfolio structure.
