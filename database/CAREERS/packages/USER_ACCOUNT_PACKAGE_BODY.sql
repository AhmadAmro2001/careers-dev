
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CAREERS"."USER_ACCOUNT_PACKAGE" As


    PROCEDURE register_new_user(v_email account.email%TYPE,  v_password account.password%TYPE)
    IS
        v_email_check number;
        v_salt account.salt%TYPE;
        v_salt_hex  account.salt%TYPE;
        v_hashed_password account.password%type;
        v_hashed_password_hex account.password%type;
        v_reset_password number := 1;
        v_is_confirmed number := 1;

    BEGIN

        IF NOT REGEXP_LIKE(v_email,'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') then
            RAISE_application_error(-20012, 'this phone number is not complete');
        end if;
        select count(*) into v_email_check from account where upper(email) = upper(v_email);
        if v_email_check > 0 then
            RAISE_application_error(-20011, 'this Email already exists');
        end if;

        v_salt := DBMS_CRYPTO.RANDOMBYTES(16); -- generate random salt
        v_salt_hex := RAWTOHEX(v_salt);

        v_hashed_password := DBMS_CRYPTO.HASH( -- hash password + salt_hex
        UTL_RAW.CAST_TO_RAW(v_password || v_salt_hex),
        DBMS_CRYPTO.HASH_SH256
        );

        v_hashed_password_hex := RAWTOHEX(v_hashed_password);

        insert into account (email,password,salt,is_confirmed, reset_password_flg)
        values(v_email, v_hashed_password_hex, v_salt_hex, v_is_confirmed, v_reset_password); -- salt_hex that you hash with it

        commit;
    end register_new_user;


    -- Function Login(p_username account.EMAIL%type, p_password VARCHAR2) Return NUMBER
    -- IS
    --     v_db_password account.password%type;
    --     v_db_salt account.salt%type;
    --     v_input_pass_hash     RAW(2000);
    --     v_input_pass_hash2    admin.password%type;
    --     v_input_pass_hash_hex VARCHAR2(2000);
    --     v_input_pass_hash_hex2 VARCHAR2(2000);
    --     v_account_id number;
    --     v_email_check number;
    --     l_admin admin%rowType;
    -- Begin

    --     if p_username is null then
    --         RAISE_application_error(-20013, 'the email is required!');
    --     end if;

    --     select count(*) into v_email_check from admin where upper(email) = upper(Trim(p_username));
    --     IF v_email_check > 0 THEN
    --         select *
    --         into l_admin
    --         from ADMIN
    --         where upper(email) = upper(trim(p_username));

    --         SELECT STANDARD_HASH(l_admin.SALT || p_password, 'SHA256')
    --         INTO v_input_pass_hash2
    --         FROM dual;

    --         IF v_input_pass_hash2 = l_admin.PASSWORD THEN
    --             RETURN 1; -- admin
    --         ELSE
    --             RAISE_application_error(-20044, 'these credentials are incorrect');
    --         END IF;
    --     END IF;

    --     select id, password, salt into v_account_id, v_db_password, v_db_salt from account where upper(email) = upper(p_username) ;

    --     v_input_pass_hash := DBMS_CRYPTO.HASH(
    --     UTL_RAW.CAST_TO_RAW(p_password || v_db_salt),
    --     DBMS_CRYPTO.HASH_SH256
    --     );

    --  v_input_pass_hash_hex := RAWTOHEX(v_input_pass_hash);

    --  if v_input_pass_hash_hex = v_db_password Then
    --     RETURN 2; -- user
    -- else
    --     RAISE_application_error(-20014, 'these credentials are incorrect');
    -- end if;

    -- EXCEPTION
    -- WHEN NO_DATA_FOUND THEN
    --     RAISE_APPLICATION_ERROR(-20015, 'User not found');

    -- end Login;

 Function Login(p_username account.EMAIL%type, p_password VARCHAR2) Return NUMBER
    IS
        v_db_password account.password%type;
        v_db_salt account.salt%type;
        v_input_pass_hash     RAW(2000);
        v_input_pass_hash2    admin.password%type;
        v_input_pass_hash_hex VARCHAR2(2000);
        v_input_pass_hash_hex2 VARCHAR2(2000);
        v_account_id number;
        v_email_check number;
        l_admin admin%rowType;
    Begin

        if p_username is null then
            RAISE_application_error(-20013, 'the email is required!');
        end if;

        select count(*) into v_email_check from admin where upper(email) = upper(Trim(p_username));
        IF v_email_check > 0 THEN
            select *
            into l_admin
            from ADMIN
            where upper(email) = upper(trim(p_username));

            -- SELECT STANDARD_HASH(l_admin.SALT || p_password, 'SHA256')
            -- INTO v_input_pass_hash2
            -- FROM dual;
            v_input_pass_hash2 := DBMS_CRYPTO.HASH(
            UTL_RAW.CAST_TO_RAW(p_password || l_admin.SALT ),
            DBMS_CRYPTO.HASH_SH256
            );

            v_input_pass_hash_hex2 := RAWTOHEX(v_input_pass_hash2);

            IF v_input_pass_hash2 = l_admin.PASSWORD THEN
                RETURN 1; -- admin
            ELSE
                RAISE_application_error(-20044, 'these credentials are incorrect');
            END IF;
        -- END IF;
        ELSE
        select id, password, salt into v_account_id, v_db_password, v_db_salt from account where upper(email) = upper(p_username) ;

        v_input_pass_hash := DBMS_CRYPTO.HASH(
        UTL_RAW.CAST_TO_RAW(p_password || v_db_salt),
        DBMS_CRYPTO.HASH_SH256
        );

     v_input_pass_hash_hex := RAWTOHEX(v_input_pass_hash);

     if v_input_pass_hash_hex = v_db_password Then
        RETURN 0; -- user
    else
        RAISE_application_error(-20014, 'these credentials are incorrect');
    end if;
    END IF;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20015, 'User not found');

    end Login;

    FUNCTION authenticate (
    p_username IN VARCHAR2,
    p_password IN VARCHAR2
        ) RETURN BOOLEAN
        IS
            l_result NUMBER;
        BEGIN
            l_result := user_account_package.login(p_username, p_password);

            -- store role
            if l_result in (1,0) then

            APEX_UTIL.SET_SESSION_STATE('G_USER_ROLE', l_result);

            RETURN TRUE;
            else
                return false;
            end if;

        EXCEPTION
            WHEN OTHERS THEN
                RETURN FALSE;
        END;


    Function Email_Check_To_Reset(v_email account.email%TYPE)return number
    IS
      v_user_id  account.id%TYPE;
      v_reset_flag number;
    BEGIN
        IF NOT REGEXP_LIKE(v_email,'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') then
            raise_application_error(-20001, 'Invalid Email format');
        END IF;
        select id, reset_password_flg into v_user_id,v_reset_flag  from account
        WHERE email = v_email;

        if v_reset_flag = 0 THEN
            return v_user_id;
        else
            return null;
        end if;

    EXCEPTION
        WHEN no_data_found then
            return null;
    end Email_Check_To_Reset;


    Function Personal_exist_check(v_account_id number)return NUMBER
    IS
      v_personal_id  number;
    BEGIN

        select id into v_personal_id from personal_info where account_id = v_account_id;
        return v_personal_id;

    EXCEPTION
        WHEN no_data_found then
            return 0;
    end Personal_exist_check;


    PROCEDURE Reset_password(v_password account.password%TYPE, v_account_id account.id%TYPE)
    IS
        v_salt account.salt%TYPE;
        v_salt_hex  account.salt%TYPE;
        v_hashed_password account.password%type;
        v_hashed_password_hex account.password%type;
        v_acc_id_check number;
        v_reset_pass_flg number := 1;

    BEGIN

        select count(*) into v_acc_id_check from account where id = v_account_id;

        if v_acc_id_check = 0 then
            RAISE_APPLICATION_ERROR(-20016, 'User not found');
        end if;

        v_salt := DBMS_CRYPTO.RANDOMBYTES(16); -- generate random salt
        v_salt_hex := RAWTOHEX(v_salt);

        v_hashed_password := DBMS_CRYPTO.HASH( -- hash password + salt_hex
        UTL_RAW.CAST_TO_RAW(v_password || v_salt_hex),
        DBMS_CRYPTO.HASH_SH256
        );

        v_hashed_password_hex := RAWTOHEX(v_hashed_password);

        update account set password = v_hashed_password_hex , salt = v_salt_hex, reset_password_flg = v_reset_pass_flg where id = v_account_id;
        commit;

    END Reset_password;



    PROCEDURE Reset_password_Current_User(v_email account.email%TYPE,v_password account.password%TYPE)
    IS
        v_salt account.salt%TYPE;
        v_salt_hex  account.salt%TYPE;
        v_hashed_password account.password%type;
        v_hashed_password_hex account.password%type;
        v_email_check number;
        v_reset_pass_flg number := 1;

    BEGIN

        select count(*) into v_email_check from account where upper(email) = upper(v_email);

        if v_email_check = 0 then
            RAISE_APPLICATION_ERROR(-20017, 'User not found');
        end if;

        v_salt := DBMS_CRYPTO.RANDOMBYTES(16); -- generate random salt
        v_salt_hex := RAWTOHEX(v_salt);

        v_hashed_password := DBMS_CRYPTO.HASH( -- hash password + salt_hex
        UTL_RAW.CAST_TO_RAW(v_password || v_salt_hex),
        DBMS_CRYPTO.HASH_SH256
        );

        v_hashed_password_hex := RAWTOHEX(v_hashed_password);

        update account set password = v_hashed_password_hex , salt = v_salt_hex, reset_password_flg = v_reset_pass_flg where upper(email) = upper(v_email);
        commit;

    END Reset_password_Current_User;


    PROCEDURE Save_User_Problems(v_email USER_PROBLEMS.USER_EMAIL%TYPE,v_problem USER_PROBLEMS.USER_PROBLEM%TYPE)
    IS
        v_user_acc_id number;
        v_check_email_exists number;
        v_check_prob_date number;
    Begin

        if v_email is null or v_problem is null then
            raise_application_error(-20152, 'All fields are required!');
        end if;
        select count(*) into v_check_email_exists from account where upper(email) = upper(v_email);
        if v_check_email_exists > 0 then
            select ID into v_user_acc_id from account where upper(email) = upper(v_email);
        else
            v_user_acc_id := null;
        end if;

        select count(*) into v_check_prob_date from USER_PROBLEMS where upper(USER_EMAIL) = upper(v_email) AND CREATED_AT >= TRUNC(SYSDATE) - 2;
        if v_check_prob_date > 0 then
            raise_application_error(-20151, 'you already submit your problem!');
        end if;

        insert into USER_PROBLEMS(USER_ACC_ID, USER_EMAIL, USER_PROBLEM)Values(v_user_acc_id, v_email, v_problem);
        commit;

    end Save_User_Problems;


end user_account_package;
/
