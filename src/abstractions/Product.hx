package abstractions;

/**
 * Represents a product.
 */
@:structInit
class Product {
	public var Id:String;
	public var Name:String;
	public var Quantity:String;
	public var Expiration:String; // change to Date or similar?
	public var Notes:String;

	public function new(id:String, name:String, quantity:String, expiration:String, notes:String) {
		Id = id;
		Name = name;
		Quantity = quantity;
		Expiration = expiration;
		Notes = notes;
	}
}
