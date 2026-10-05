
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CAREERS"."JOB_APPLICATION_PKG" As



    Function Save_Job_application(v_resume varchar2, v_account_id job_application.account_id%type) return number
    IS
        v_account_check number;
        v_resume_blob blob;
        v_resume_filename varchar2(300);
        v_resume_mime_type varchar2(300);
        v_application_id NUMBER;
        v_Resume_file_type_id number := 2;
        v_attachment_id number;
    Begin
        select count(*) into v_account_check from account where id = v_account_id;
        if v_account_check = 0 then
            raise_application_error(-20040, 'this account does not exist!');
        end if;

        SELECT blob_content, filename, mime_type
        INTO v_resume_blob, v_resume_filename, v_resume_mime_type
        FROM apex_application_temp_files
        WHERE name = v_resume;

        insert into JOB_APPLICATION_ATTACHMENTS(ACCOUNT_ID, FILE_BLOB, FILE_NAME, MIME_TYPE, FILE_TYPE_ID)
        values(v_account_id, v_resume_blob, v_resume_filename, v_resume_mime_type, v_Resume_file_type_id)
        RETURNING ID
        INTO v_attachment_id;

        insert into job_application(RESUME_FILE_ID, ACCOUNT_ID)values(v_attachment_id, v_account_id)
        RETURNING id into v_application_id;
        commit;
        return v_application_id;


        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20041, 'Uploaded file not found');
    END Save_Job_application;




    PROCEDURE Save_other_certificates(v_application_id JOB_APPLICATION_CERTIFICATE.job_application_id%type,
    v_certificate_name JOB_APPLICATION_CERTIFICATE.CERTIFICATE_NAME%type, v_date JOB_APPLICATION_CERTIFICATE.DATE_OF_ACQUISITION%type)
    IS

    Begin
        if v_application_id is null then
            RAISE_APPLICATION_ERROR(-20044, 'app id is required!');
        end if;

        if v_certificate_name is null then
            RAISE_APPLICATION_ERROR(-20045, 'name is required!');
        end if;

        if v_date is null then
            RAISE_APPLICATION_ERROR(-20046, 'date is required!');
        end if;

--        if v_application_id is null or v_certificate_name is null or v_date is null then
--            RAISE_APPLICATION_ERROR(-20042, 'all fields are required!');
--        end if;

        insert into JOB_APPLICATION_CERTIFICATE(job_application_id, CERTIFICATE_NAME, DATE_OF_ACQUISITION)
        values(v_application_id, v_certificate_name, v_date);
        commit;


    end Save_other_certificates;


    PROCEDURE Save_Vacancy_application(v_application_id JOB_VACANCY_APPLICATION.APPLICATION_ID%type, v_vacancy_id JOB_VACANCY_APPLICATION.VACANCY_ID%type)
    IS

       v_vacancy_app_check number;
       v_account_id number;
    Begin

        if v_application_id is null or v_vacancy_id is null then
            RAISE_APPLICATION_ERROR(-20043, 'all fields are required!');
        end if;
        SELECT ACCOUNT_ID
        INTO v_account_id
        FROM JOB_APPLICATION
        WHERE ID = v_application_id;

        SELECT COUNT(*)
        INTO v_vacancy_app_check
        FROM JOB_VACANCY_APPLICATION jva
        WHERE jva.VACANCY_ID = v_vacancy_id
          AND jva.APPLICATION_ID IN (
              SELECT ja.ID
              FROM JOB_APPLICATION ja
              WHERE ja.ACCOUNT_ID = v_account_id
          );

        if v_vacancy_app_check > 0 then
             RAISE_APPLICATION_ERROR(-20090, 'you already applied for this job!');
        end if;

        insert into JOB_VACANCY_APPLICATION(APPLICATION_ID, VACANCY_ID)
        values(v_application_id, v_vacancy_id);
        commit;


    end Save_Vacancy_application;



    function check_application_vacancy(v_personal_id NUMBER, v_vacancy_id number) return number
    IS
        v_application_vacancy_check number;
        v_account_id number;
    BEGIN

        IF v_personal_id IS NULL THEN
            RETURN -1;
        END IF;


        IF v_vacancy_id IS NULL THEN
            RETURN 0;
        END IF;

        select account_id into v_account_id from personal_info where id = v_personal_id;
        select count(*) into v_application_vacancy_check from JOB_VACANCY_APPLICATION where vacancy_id = v_vacancy_id and APPLICATION_ID in (
            select id from job_application where account_id = v_account_id
        );

        RETURN v_application_vacancy_check;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN -1;





    END check_application_vacancy;

    function check_application_vacancy_count_per_user(v_personal_id NUMBER) return number
    IS
        v_vacancies_count number;
        v_account_id number;
    BEGIN

        IF v_personal_id IS NULL THEN
            RETURN -1;
        END IF;

        select account_id into v_account_id from personal_info where id = v_personal_id;
        select count(*) into v_vacancies_count from JOB_VACANCY_APPLICATION where APPLICATION_ID in (
            select id from job_application where account_id = v_account_id
        );

        return v_vacancies_count;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN -1;
    END check_application_vacancy_count_per_user;



    function check_complete_personal_info(v_account_id number)return number
    IS
        personal_info_check number;
        education_check number;
        language_check number;
        experience_check number;
        v_personal_id number;
    BEGIN


        select count(*) into personal_info_check from personal_info where account_id = v_account_id;
        select id into v_personal_id from personal_info where account_id = v_account_id;
        select count(*) into education_check from EDUCATION_DEGREE where personal_id = v_personal_id;
        select count(*) into language_check from JOB_APPLICATION_LANGUAGE where personal_id = v_personal_id;
        select count(*) into experience_check from JOB_APPLICATION_EXPERIENCE where personal_id = v_personal_id;

        IF education_check > 0
           AND language_check > 0
           AND experience_check > 0
        THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;


        return 1;

        Exception
            when no_data_found then
                return 0;

    End check_complete_personal_info;





end Job_application_pkg;
/
