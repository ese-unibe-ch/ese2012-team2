##Code Review##
===========

#Design
- no violation of MVC, code nicely separated in model, view and controller
- controllers don’t do heavy lifting, which is done by models -> nice!
- nice inheritance chain for controllers which improves code reuse
- interactions of models seem consistent and reasonable
- responsibility is nicely distributed among different models/objects, no God classes or data only classes (except data overlay ;-))
- distinction between responsibilities of models and model-helpers are foggy, some models have limited responsibility in contrast to the helper
- code seems nicely organized, usage of modules could be improved (helper classes do not belong to a module)
- nice code reuse in views using partials, even for tiny bits of code ;-)
- very cool handling of traders, users and organizations, e.g. overloading methods on user and delegating to trader or organization
- well done error handling using exceptions, be careful to not use exceptions for control flow though

---

#Coding Style
- some inconsistencies with method parameters: with brackets or without brackets -> use one or the other, no brackets for one parameter, brackets for multiple parameters
- no unnecessary return statements
- cool use of operator overloading ( << events)
- could use more suffix conditionals (e.g if cond then stat -> stat if cond)
- very good naming for methods and variables
- not using assertions or contracts, so valid parameter values are not clear to the user of the API, what happens when value is not valid?
- almost no testing against nil value parameters or values (-> use contracts to enforce valid parameters)
- encapsulation using accessors in models and non public instance variables where data must not be visible -> very nice
- good use of helper/utility classes and methods, be careful about responsibilities though

---

#Documentation
- almost no class comments, so the responsibilities of the classes are not clear without reading the code, you should always write a class comment for every class
- code is pretty much self documentary: method and variable names are very carefully chosen, no a, b, tmp, x, y -> great! No unnecessary documentation...
- should use contracts in method documentation -> see coding style

---

#Tests
- test cases are distinct but the tests are only running together, you can not drive a test separately
- stating test cases would be easier with Rspec, ruby does not encourage long test method names
- there are untested (or very sparsely) tested classes (e.g. data overlay)
- good use of before and teardown overrides
- well tested exception cases
