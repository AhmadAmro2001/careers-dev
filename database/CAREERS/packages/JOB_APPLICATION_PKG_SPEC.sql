
  CREATE OR REPLACE EDITIONABLE PACKAGE "CAREERS"."JOB_APPLICATION_PKG" As



    Function Save_Job_application(v_resume varchar2, v_account_id job_application.account_id%type) return number;

    PROCEDURE Save_other_certificates(v_application_id JOB_APPLICATION_CERTIFICATE.job_application_id%type,
    v_certificate_name JOB_APPLICATION_CERTIFICATE.CERTIFICATE_NAME%type, v_date JOB_APPLICATION_CERTIFICATE.DATE_OF_ACQUISITION%type);

    PROCEDURE Save_Vacancy_application(v_application_id JOB_VACANCY_APPLICATION.APPLICATION_ID%type,
    v_vacancy_id JOB_VACANCY_APPLICATION.VACANCY_ID%type);

    function check_application_vacancy(v_personal_id NUMBER, v_vacancy_id number) return number;

    function check_application_vacancy_count_per_user(v_personal_id NUMBER) return number;

    function check_complete_personal_info(v_account_id number)return number;

end Job_application_pkg;
/
