# Changelog

0.2.1 2014-02-16
------------------

+ Add ``[YapModelObject findFirstWithIndex:query:]``.

0.2.0 2014-02-16
------------------

+ Add ``[YapModelObject asyncTransaction:completion:completionQueue:]`` to allow specify queue for completion blcok. (e0e2c033)
+ Add ``[YapModelManager transactionForCurrentThread]`` and ``[YapModelManager setTransactionForCurrentThread]`` to simplify concurrent transactions. (e0e2c033)
* Read-only shorthand methods (where, find, findWithKeys, findWithIndex:query) in YapModelObject now use read transaction. (6eff823)

0.1.0 2014-02-16
------------------

+ Initial release.