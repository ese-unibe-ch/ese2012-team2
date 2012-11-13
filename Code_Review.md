===========
Code Review
===========

- No violation of MVC, code nicely separated in model, view and controller
-controllers don’t do heavy lifting, which is done by models -> nice!
Nice inheritance chain for controllers which improves code reuse
interactions of models seem consistent and reasonable
responsibility is nicely distributed among different models/objects, no god classes or data only classes (except data overlay ;-))
distinction between responsibilities of models and model-helpers are foggy, some models have limited responsibility in contrast to the helper
code seems nicely organized, usage of Modules could be improved (helper classes do not belong to a module)
Nice code reuse in views using partials, even for tiny bits of code ;-)
very cool handling of traders, users and organizations, e.g. overloading methods on user and delegating to trader or organization
well done error handling using exceptions. Be careful to not use exceptions for control flow though