package org.example;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

@Entity
public class Product {
    @Id
    @GeneratedValue(
    strategy = GenerationType.AUTO)
    private int dbID;
    private String ProductName;
    private int UnitsOnStock;

    public Product(){}

    public Product(String ProductName, int UnitsOnStock){
        this.ProductName = ProductName;
        this.UnitsOnStock = UnitsOnStock;
    }

}
