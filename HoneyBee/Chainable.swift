
/// Generated protocol declaring erroring chain functions.
protocol ErroringChainable  {
	associatedtype B
	associatedtype P: AsyncBlockPerformer

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) throws -> C ) -> Link<C, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) throws -> Void ) -> Link<B, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> () throws -> C ) -> Link<C, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> () throws -> Void ) -> Link<B, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (((Error?) -> Void)?) -> Void ) -> Link<B, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping ((() -> Void)?) throws -> Void ) -> Link<B, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (((C) -> Void)?) throws -> Void ) -> Link<C, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, ((Error?) -> Void)?) -> Void ) -> Link<B, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, (() -> Void)?) throws -> Void ) -> Link<B, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (((C?, Error?) -> Void)?) -> Void ) -> Link<C, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, ((C) -> Void)?) throws -> Void ) -> Link<C, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (((Error?) -> Void)?) -> Void ) -> Link<B, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (@escaping (Error?) -> Void) -> Void ) -> Link<B, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, ((C?, Error?) -> Void)?) -> Void ) -> Link<C, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> ((() -> Void)?) throws -> Void ) -> Link<B, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (@escaping () -> Void) throws -> Void ) -> Link<B, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (@escaping (C) -> Void) throws -> Void ) -> Link<C, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (((C) -> Void)?) throws -> Void ) -> Link<C, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, @escaping (Error?) -> Void) -> Void ) -> Link<B, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (((C?, Error?) -> Void)?) -> Void ) -> Link<C, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, @escaping () -> Void) throws -> Void ) -> Link<B, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (@escaping (C?, Error?) -> Void) -> Void ) -> Link<C, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, @escaping (C) -> Void) throws -> Void ) -> Link<C, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B, @escaping (C?, Error?) -> Void) -> Void ) -> Link<C, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (@escaping (Error?) -> Void) -> Void ) -> Link<B, P>

///Creates a new Link which passes through argument of type B and appends the link to the execution list of this Link
@discardableResult
func chain(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (@escaping () -> Void) throws -> Void ) -> Link<B, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (@escaping (C) -> Void) throws -> Void ) -> Link<C, P>

///Creates a new Link which transforms argument of type B to type C and appends the link to the execution list of this Link
@discardableResult
func chain<C>(file: StaticString, line: UInt, functionDescription: String?, _ function: @escaping (B) -> (@escaping (C?, Error?) -> Void) -> Void ) -> Link<C, P>

}

