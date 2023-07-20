/**
    @author: Dylan Chorley
    @date: 20-Sep-2022
    @group: Wrapper classes
    @description: Wrapper for user to the count of the number of opportunities they own
    @test class: UserCountWraperTest
**/
public with sharing class UserCountWrapper implements Comparable{
    private static Map<Id, User> userList = new Map<Id, User>([SELECT Id, Name FROM USER]); 
    private Id owner;
    private Integer count;

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Constructor
        @param: owner id and count for that owner
        @return: none
    **/
    public UserCountWrapper(Id owner, Integer count) {
        this.owner = owner;
        this.count = count;
    }
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Compares to wrapper objects to eachother
        @param: another usercountwrapper object
        @return: 0 if both have equal counts, 1 if count of first is greater than param and -1 if opposite is true
    **/
    public Integer compareTo(Object other){
        UserCountWrapper wrother = (UserCountWrapper) other;
        if(count == wrother.count){
            return 0;
        }
        else if(count > wrother.count){
            return 1;
        }
        else{
            return -1;
        }
    }
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Adds count to particular count field for usercountwrapper class
        @param: none
        @return: Adds one to the count
    **/
    public void addCount(){
        this.count+=1;
    }

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Gets the user owner id
        @param: none
        @return: id (owner id)
    **/
    public Id getUser(){
        return this.owner;
    }

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Gets the count for particular owner/wrapper
        @param: none
        @return: count of opportunities user owns
    **/
    public Integer getCount(){
        return this.count;
    }

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Gets the user name of owner
        @param: none
        @return: string form of owner's name
    **/
    public String getUserName(){
        return userList.get(this.owner).Name;
    }

}