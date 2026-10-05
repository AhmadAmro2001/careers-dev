
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CAREERS"."USER_PERSONAL_INFO_PKG" as



    PROCEDURE Complete_account_data(v_first_name account.first_name%type, v_second_name account.SECOND_NAME%type ,
        v_last_name account.LAST_NAME%type, v_date_of_birth account.DATE_OF_BIRTH%TYPE, v_gender account.gender%type,
        v_email account.email%TYPE, v_home_telephone account.HOME_TELEPHONE%TYPE, v_address account.ADDRESS%TYPE, v_city_id account.CITY_ID%type,
        v_nat_id account.NATIONAL_ID%type, v_passport_number account.PASSPORT_NUMBER%type, v_country_id account.country_id%TYPE,
        v_country_phone_code account.COUNTRY_PHONE_CODE_ID%type, v_mobile_telephone account.mobile_telephone%type , v_user_id account.id%type)

    IS
        v_email_check number;
        v_nat_id_check number;
        v_user_exists number;
    BEGIN

        if v_first_name is null or v_second_name is null or v_last_name is null
        or v_date_of_birth is null or v_gender is null or v_email is null or v_home_telephone is null
        or v_address is null or v_city_id is NULL
        or v_country_id is null or v_country_phone_code is null or v_mobile_telephone is null or
        v_user_id is null then
            raise_application_error(-20022, 'all fields are required!');
        end if;
        IF NOT REGEXP_LIKE(v_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
            RAISE_APPLICATION_ERROR(-20030, 'Invalid email format');
        END IF;
        select count(*) into v_email_check from account where email = v_email and id <> v_user_id;
        if v_email_check > 0 then
            raise_application_error(-20020, 'this email already exists please enter another email!');
        end if;

        select count(*) into v_nat_id_check from account where NATIONAL_ID = v_nat_id and id <> v_user_id;
        if v_nat_id_check > 0 then
            raise_application_error(-20080, 'this national id already exists please enter another national id!');
        end if;

        if v_nat_id is null and v_passport_number is null then
            raise_application_error(-20021, 'please enter your national id or passport number');
        end if;


        update account set first_name = v_first_name, SECOND_NAME = v_second_name, LAST_NAME = v_last_name,
        DATE_OF_BIRTH =v_date_of_birth , gender = v_gender, email = v_email, HOME_TELEPHONE = v_home_telephone, MOBILE_TELEPHONE = v_mobile_telephone,
        ADDRESS = v_address, city_id = v_city_id, NATIONAL_ID = v_nat_id, PASSPORT_NUMBER = v_passport_number, country_id = v_country_id,
        COUNTRY_PHONE_CODE_ID = v_country_phone_code where id = v_user_id;

        IF SQL%ROWCOUNT = 0 THEN
            SELECT COUNT(*) INTO v_user_exists FROM account WHERE id = v_user_id;

            IF v_user_exists = 0 THEN
                RAISE_APPLICATION_ERROR(-20023, 'User not found');
            END IF;
        END IF;
        commit;

    end Complete_account_data;


    PROCEDURE Save_Personal_data(v_marital_status personal_info.marital_status%type, v_military_status personal_info.MILITARY_STATUS%type,
        v_mother_full_name personal_info.MOTHER_FULL_NAME%type,v_image VARCHAR2, v_account_id number, v_personal_id OUT NUMBER)
    IS
        v_natId_image_file_name varchar2(300);
        v_natId_image_mime_type varchar2(300);
        v_natId_image_blob blob;
        v_acc_id_check number;
        v_nat_id_file_type_id number := 21;
        v_attachment_id number;
        v_check_acc_in_personal number;

    Begin

        if v_marital_status is null or v_military_status is null or v_mother_full_name is null or v_image is null or v_account_id is null then
            RAISE_APPLICATION_ERROR(-20024, 'All Fields are required!');
        end if;

        select count(*) into v_acc_id_check from account where id = v_account_id;
        if v_acc_id_check = 0 then
            RAISE_APPLICATION_ERROR(-20025, 'Account not found');
        end if;

        select count(*) into  v_check_acc_in_personal from personal_info where ACCOUNT_ID = v_account_id;
        if v_check_acc_in_personal > 0 then
            RAISE_APPLICATION_ERROR(-200150, 'This account already save this data');
        end if;


        SELECT blob_content,
           filename,
           mime_type
        INTO   v_natId_image_blob,
               v_natId_image_file_name,
               v_natId_image_mime_type
        FROM   apex_application_temp_files
        WHERE  name = v_image;


        insert into JOB_APPLICATION_ATTACHMENTS(ACCOUNT_ID, FILE_BLOB, FILE_NAME, MIME_TYPE, FILE_TYPE_ID)
        values(v_account_id, v_natId_image_blob, v_natId_image_file_name, v_natId_image_mime_type, v_nat_id_file_type_id)
        RETURNING ID
        INTO v_attachment_id;

        insert into personal_info(ACCOUNT_ID, MOTHER_FULL_NAME, MARITAL_STATUS, MILITARY_STATUS, NATIONAL_ID_FILE_ID)
        values(v_account_id, v_mother_full_name, v_marital_status, v_military_status, v_attachment_id)
        RETURNING id INTO v_personal_id;

        commit;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20026, 'Uploaded file not found');

    End Save_Personal_data;


    Procedure save_education_degree(v_education_level education_degree.education_level%type,
    v_education_field education_degree.education_field%type, v_grad_year education_degree.GRADUATION_YEAR%type,
    v_grade education_degree.EDUCATION_GRADE%type, v_university education_degree.UNIVERSITY%type,
    v_other_field education_degree.OTHER_EDUCATION_FIELD%type, v_personal_id education_degree.PERSONAL_ID%type, v_Grad_image Varchar2)
    IS
        v_personal_id_check number;
        v_Grad_image_file_name varchar2(300);
        v_Grad_image_mime_type varchar2(300);
        v_Grad_image_blob blob;
        v_edu_exist_check number;
        v_attachment_id number;
        v_account_id number;
--        v_attachment_id number;
        v_Grad_cert_file_type_id number := 1;
    BEGIN
        if v_education_level is null or v_grad_year is null or v_grade is null or v_university is null or v_personal_id is null or
        (v_education_field is null and v_other_field is null) then
            RAISE_APPLICATION_ERROR(-20030, 'All Fields are required!');
        end if;
        select count(*) into v_personal_id_check from personal_info where id = v_personal_id;
        select count(*) into v_edu_exist_check from education_degree where EDUCATION_LEVEL = v_education_level and EDUCATION_FIELD = v_education_field
        and PERSONAL_ID = v_personal_id;

        select account_id into v_account_id from personal_info where id = v_personal_id;

        if v_personal_id_check = 0 then
            RAISE_APPLICATION_ERROR(-20031, 'No personal info with this id!');
        end if;

        if v_edu_exist_check > 0 then
            RAISE_APPLICATION_ERROR(-20050, 'this education already added!');
        end if;

        SELECT blob_content,
               filename,
               mime_type
        INTO   v_Grad_image_blob,
               v_Grad_image_file_name,
               v_Grad_image_mime_type
        FROM apex_application_temp_files
        WHERE name = v_Grad_image;

        insert into JOB_APPLICATION_ATTACHMENTS(ACCOUNT_ID, FILE_BLOB, FILE_NAME, MIME_TYPE, FILE_TYPE_ID)
        values(v_account_id, v_Grad_image_blob, v_Grad_image_file_name, v_Grad_image_mime_type, v_Grad_cert_file_type_id)
        RETURNING ID
        INTO v_attachment_id;

        insert into education_degree(EDUCATION_LEVEL, EDUCATION_FIELD, GRADUATION_YEAR, EDUCATION_GRADE,
        UNIVERSITY, OTHER_EDUCATION_FIELD, GRADUATION_CERTIFICATE_FILE_ID,
        PERSONAL_ID)
        values(v_education_level, v_education_field, v_grad_year, v_grade,
        v_university, v_other_field, v_attachment_id, v_personal_id);

        commit;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20032, 'Uploaded file not found');
    END save_education_degree;



    PROCEDURE Update_Personal_data(v_marital_status personal_info.marital_status%type, v_military_status personal_info.MILITARY_STATUS%type,
        v_mother_full_name personal_info.MOTHER_FULL_NAME%type,v_image VARCHAR2, v_id NUMBER)
    IS
        v_natId_image_file_name varchar2(300);
        v_natId_image_blob blob;
        v_personal_id_check number;
        v_NATIONAL_ID_FILE_ID number;
        v_natId_image_mime_type varchar2(300);

    Begin

        if v_marital_status is null or v_military_status is null or v_mother_full_name is null or v_id is null then
            RAISE_APPLICATION_ERROR(-20033, 'All Fields are required!');
        end if;

        select count(*) into v_personal_id_check from personal_info where id = v_id;
        if v_personal_id_check = 0 then
            RAISE_APPLICATION_ERROR(-20034, 'invalid id!');
        end if;
        select NATIONAL_ID_FILE_ID into v_NATIONAL_ID_FILE_ID from personal_info where id = v_id;
        if v_image is null then
--            select NATIONAL_ID_FILE_ID into v_NATIONAL_ID_FILE_ID from personal_info where id = v_id;
            select FILE_BLOB, FILE_NAME, MIME_TYPE into v_natId_image_blob, v_natId_image_file_name, v_natId_image_mime_type
            from JOB_APPLICATION_ATTACHMENTS where id = v_NATIONAL_ID_FILE_ID;
        else
            SELECT blob_content,
           filename,
           mime_type
        INTO   v_natId_image_blob,
               v_natId_image_file_name,
               v_natId_image_mime_type
        FROM   apex_application_temp_files
        WHERE  name = v_image;

        end if;

        update JOB_APPLICATION_ATTACHMENTS set FILE_BLOB = v_natId_image_blob, FILE_NAME = v_natId_image_file_name, MIME_TYPE = v_natId_image_mime_type
        where id = v_NATIONAL_ID_FILE_ID;

        update personal_info set MOTHER_FULL_NAME = v_mother_full_name,
        MARITAL_STATUS = v_marital_status,
        MILITARY_STATUS = v_military_status where id = v_id;

        commit;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20035, 'Uploaded file not found');

    End Update_Personal_data;

    PROCEDURE Update_Education_data(v_edu_level_id Education_degree.EDUCATION_LEVEL%type, v_edu_field_id Education_degree.EDUCATION_FIELD%type,
        v_grad_year Education_degree.GRADUATION_YEAR%type, v_edu_grade Education_degree.EDUCATION_GRADE%type,
        v_university Education_degree.UNIVERSITY%type, v_other_field Education_degree.OTHER_EDUCATION_FIELD%type ,v_image VARCHAR2, v_id NUMBER)
    IS
        v_Grad_image_file_name varchar2(300);
        v_Grad_image_blob blob;
        v_education_check number;
        v_Grad_Cer_FILE_ID number;
        v_Grad_Cer_mime_type varchar2(300);
        v_attachment_id number;
        v_pers_id number;
        v_acc_id number;
        v_Grad_Cer_file_type_id number := 1;

    Begin

        if v_edu_level_id is null or (v_edu_field_id is null and v_other_field is null) or v_grad_year is null or v_id is null
        or v_edu_grade is null or v_university is null  then
            RAISE_APPLICATION_ERROR(-20036, 'All Fields are required!');
        end if;

        select count(*) into v_education_check from education_degree where id = v_id;
        if v_education_check = 0 then
            RAISE_APPLICATION_ERROR(-20037, 'invalid id!');
        end if;
        select GRADUATION_CERTIFICATE_FILE_ID, personal_id into v_Grad_Cer_FILE_ID, v_pers_id from Education_Degree where id = v_id;
        select account_id into v_acc_id from personal_info where id = v_pers_id;
        if v_image is null then
            select FILE_BLOB, FILE_NAME, MIME_TYPE into v_Grad_image_blob, v_Grad_image_file_name, v_Grad_Cer_mime_type
            from JOB_APPLICATION_ATTACHMENTS where id = v_Grad_Cer_FILE_ID;
        else
            SELECT blob_content,
               filename,
               mime_type
            INTO   v_Grad_image_blob,
                   v_Grad_image_file_name,
                   v_Grad_Cer_mime_type
            FROM apex_application_temp_files
            WHERE name = v_image;

        end if;

        if v_Grad_Cer_FILE_ID is null then
            insert into JOB_APPLICATION_ATTACHMENTS(ACCOUNT_ID, FILE_BLOB, FILE_NAME, MIME_TYPE, FILE_TYPE_ID)
        values(v_acc_id, v_Grad_image_blob, v_Grad_image_file_name, v_Grad_Cer_mime_type, v_Grad_Cer_file_type_id)
        RETURNING ID
        INTO v_attachment_id;

        update education_degree set GRADUATION_CERTIFICATE_FILE_ID = v_attachment_id;
        end if;

        update JOB_APPLICATION_ATTACHMENTS set FILE_BLOB = v_Grad_image_blob, FILE_NAME = v_Grad_image_file_name, MIME_TYPE = v_Grad_Cer_mime_type
        where id = v_Grad_Cer_FILE_ID;



        update education_degree set EDUCATION_LEVEL = v_edu_level_id, EDUCATION_FIELD = v_edu_field_id,
           GRADUATION_YEAR = v_grad_year, EDUCATION_GRADE = v_edu_grade,
           UNIVERSITY = v_university, OTHER_EDUCATION_FIELD = v_other_field where id = v_id;

        commit;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20035, 'Uploaded file not found');

    End Update_Education_data;



end user_personal_info_pkg;
/
