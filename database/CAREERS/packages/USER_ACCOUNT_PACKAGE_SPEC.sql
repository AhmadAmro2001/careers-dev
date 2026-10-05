
  CREATE OR REPLACE EDITIONABLE PACKAGE "CAREERS"."USER_ACCOUNT_PACKAGE" As


    PROCEDURE register_new_user(v_email account.email%TYPE,  v_password account.password%TYPE);

    PROCEDURE Reset_password(v_password account.password%TYPE, v_account_id account.id%TYPE);

    PROCEDURE Reset_password_Current_User(v_email account.email%TYPE,v_password account.password%TYPE);

    PROCEDURE Save_User_Problems(v_email USER_PROBLEMS.USER_EMAIL%TYPE,v_problem USER_PROBLEMS.USER_PROBLEM%TYPE);

    Function  Login(p_username account.EMAIL%type, p_password varchar2) Return NUMBER;

    Function Email_Check_To_Reset(v_email account.email%TYPE)return NUMBER;

    Function Personal_exist_check(v_account_id number)return NUMBER;



    FUNCTION authenticate (
    p_username IN VARCHAR2,
    p_password IN VARCHAR2
        ) RETURN BOOLEAN;

end user_account_package;
/
