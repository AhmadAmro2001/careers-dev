
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CAREERS"."PKG_ADMIN" AS

    FUNCTION admin_login(
        p_username IN VARCHAR2
    ) RETURN VARCHAR2
    IS
        v_admin_found Admin%ROWTYPE;
        v_input_hash    VARCHAR2(64);
    BEGIN
        SELECT *
        INTO v_admin_found
        FROM admin
        WHERE LOWER(email) = LOWER(p_username) AND (IS_CAREER_ADMIN = 1 OR Is_Super_Admin = 1) AND Is_Blocked = 0 ;

        -- 0 means admin must reset password
        IF v_admin_found.RESET_PASS = 0 THEN
            RETURN 'RESET_REQUIRED';

        ELSIF v_admin_found.RESET_PASS = 1 THEN
                RETURN 'SUCCESS';
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'INVALID';
    END admin_login;


    PROCEDURE reset_admin_password(
        p_username     IN VARCHAR2,
        p_new_password IN VARCHAR2
    )
    IS
        v_salt Admin.salt%TYPE;
        v_salt_hex  Admin.salt%TYPE;
        v_hash Admin.password%type;
        v_hashed_password_hex Admin.password%type;
    BEGIN


        v_salt := DBMS_CRYPTO.RANDOMBYTES(16); -- generate random salt
        v_salt_hex := RAWTOHEX(v_salt);



        v_hash := DBMS_CRYPTO.HASH( -- hash password + salt_hex
        UTL_RAW.CAST_TO_RAW(p_new_password || v_salt_hex),
        DBMS_CRYPTO.HASH_SH256
        );

        v_hashed_password_hex := RAWTOHEX(v_hash);



        UPDATE admin
        SET password = v_hashed_password_hex,
            salt = v_salt_hex,
            reset_pass = 1
        WHERE LOWER(email) = LOWER(TRIM(p_username)) and (
            NVL(IS_CAREER_ADMIN, 0) = 1
            OR NVL(IS_SUPER_ADMIN, 0) = 1
          );


    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001,'this admin is not found');

    END reset_admin_password;


     PROCEDURE archive_application(
        p_application_id IN NUMBER
    )
    IS
    BEGIN
        UPDATE Job_Application
        SET IS_ARCHIVED = 1 , ARCHIVED_DATE = sysdate
        WHERE ID = p_application_id;



    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001,'this job application is not found');
    END archive_application ;


    PROCEDURE unarchive_application(
        p_application_id IN NUMBER
    )
    IS
    BEGIN
        UPDATE Job_Application
        SET IS_ARCHIVED = 0
        WHERE ID = p_application_id;



    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001,'this job application is not found');
    END unarchive_application ;

    PROCEDURE edit_vacancy(
        p_vacancy_id IN NUMBER,
        p_title IN VARCHAR2 DEFAULT NULL,
        p_summary IN CLOB DEFAULT NULL,
        p_qualifications IN CLOB DEFAULT NULL,
        p_responsibilities IN CLOB DEFAULT NULL,
        p_category_id IN NUMBER DEFAULT NULL,
        p_minimum_education_level_id IN NUMBER DEFAULT NULL,
        p_is_ministry_exclusive IN NUMBER DEFAULT NULL,
        p_updated_by IN VARCHAR2,
        p_title_code in varchar2 DEFAULT NULL,
        p_area_id in number DEFAULT NULL
    )
    IS
        v_vacancy Job_Vacancy%ROWTYPE;
        v_admin_name Admin.name%TYPE;
    BEGIN
        SELECT NAME
        INTO v_admin_name
        FROM Admin
        WHERE ID = p_updated_by;

        UPDATE Job_Vacancy

        SET
            Title = CASE
                WHEN p_title IS NOT NULL THEN p_title
                ELSE title
                END,
            TITLE_CODE = case
                when p_title_code is not null then p_title_code
                else TITLE_CODE
                end ,
            summary = CASE
                WHEN p_summary IS NOT NULL THEN p_summary
                ELSE summary
                END,

            qualifications = CASE
                WHEN p_qualifications IS NOT NULL THEN p_qualifications
                ELSE qualifications
                END,

            responsibilities = CASE
                WHEN p_responsibilities IS NOT NULL THEN p_responsibilities
                ELSE responsibilities
                END,

            category_id = CASE
                WHEN p_category_id IS NOT NULL THEN p_category_id
                ELSE category_id
                END,

            minimum_education_level_id = CASE
                WHEN p_minimum_education_level_id IS NOT NULL
                THEN p_minimum_education_level_id
                ELSE minimum_education_level_id
                END,

            is_ministry_exclusive = CASE
                WHEN p_is_ministry_exclusive IS NOT NULL
                THEN p_is_ministry_exclusive
                ELSE is_ministry_exclusive
                END,
            Last_Update_Date = SYSDATE,
            AREA_ID = case
                when p_area_id is not null
                then p_area_id
                else AREA_ID
                end,
            Last_Updated_By = v_admin_name
        WHERE ID = p_vacancy_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001,'no data found');
    END edit_vacancy;

    PROCEDURE archive_vacancy(
        p_vacancy_id IN NUMBER
    )
    IS
    BEGIN
        UPDATE Job_Vacancy
        SET Is_Archived = 1 , Last_Update_Date = sysdate
        WHERE ID = p_vacancy_id;



    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001,'this vacancy is not found');
    END archive_vacancy ;

     PROCEDURE unarchive_vacancy(
        p_vacancy_id IN NUMBER
    )
    IS
    BEGIN
        UPDATE Job_Vacancy
        SET Is_Archived = 0 , Last_Update_Date = sysdate
        WHERE ID = p_vacancy_id;



    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001,'this vacancy is not found');
    END unarchive_vacancy ;

    PROCEDURE create_new_vacancy(
        p_new_title IN VARCHAR2,
        p_new_category_id IN NUMBER,
        p_new_summary IN CLOB,
        p_new_responsibilities IN CLOB,
        p_new_qualifications IN CLOB,
        p_new_education_id IN NUMBER,
        p_new_vacancy_type IN NUMBER,
        p_admin_user IN VARCHAR2,
        p_title_code in varchar2,
        p_area_id in number
    )
    IS
        v_admin_available number;
    BEGIN
        SELECT count(*)
        INTO v_admin_available
        FROM Admin
        WHERE UPPER(ID) = UPPER(p_admin_user)
        AND (IS_CAREER_ADMIN = 1 or Is_Super_Admin = 1)
        AND Is_Blocked = 0 ;

        IF v_admin_available = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Unauthorized administrator access.');
        END IF;

        INSERT INTO Job_Vacancy (
            Title,
            Summary ,
            Qualifications ,
            Responsibilities ,
            Category_ID ,
            Is_Archived ,
            Created_By ,
            Is_Ministry_Exclusive ,
            Minimum_Education_Level_ID,
            TITLE_CODE,
            AREA_ID
        ) VALUES (
            p_new_title,
            p_new_summary,
            p_new_qualifications,
            p_new_responsibilities,
            p_new_category_id,
            0,
            p_admin_user,
            p_new_vacancy_type,
            p_new_education_id,
            p_title_code ,
            p_area_id
        );
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001,'no admin found');
    END create_new_vacancy ;



   FUNCTION reset_pass_check(
    p_email IN VARCHAR2
) RETURN VARCHAR2
IS
    admin_check   NUMBER;
    user_check    NUMBER;
    admin_account Admin%ROWTYPE;
    user_account  Account%ROWTYPE;
BEGIN
    SELECT COUNT(*)
    INTO admin_check
    FROM Admin
    WHERE UPPER(email) = UPPER(p_email);

    SELECT COUNT(*)
    INTO user_check
    FROM Account
    WHERE UPPER(email) = UPPER(p_email);

    IF admin_check > 0 AND user_check = 0 THEN

        SELECT *
        INTO admin_account
        FROM Admin
        WHERE UPPER(email) = UPPER(p_email);

        IF admin_account.RESET_PASS = 0 THEN
            RETURN 'RESET_ADMIN';
        ELSE
            RETURN 'NO_RESET';
        END IF;

    ELSIF admin_check = 0 AND user_check > 0 THEN

        SELECT *
        INTO user_account
        FROM Account
        WHERE UPPER(email) = UPPER(p_email);

        IF user_account.RESET_PASSWORD_FLG = 0 THEN
            RETURN 'RESET_USER';
        ELSE
            RETURN 'NO_RESET';
        END IF;

    ELSE
        RETURN 'NO_RESET';
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'NO_RESET';
END reset_pass_check;
END PKG_ADMIN;
/
