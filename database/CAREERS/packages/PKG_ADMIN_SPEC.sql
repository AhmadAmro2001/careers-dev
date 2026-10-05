
  CREATE OR REPLACE EDITIONABLE PACKAGE "CAREERS"."PKG_ADMIN" AS
    FUNCTION admin_login(
        p_username IN VARCHAR2
    )RETURN VARCHAR2;

    PROCEDURE reset_admin_password(
        p_username     IN VARCHAR2,
        p_new_password IN VARCHAR2
    );

    PROCEDURE archive_application(
        p_application_id IN NUMBER
    );

    PROCEDURE unarchive_application(
        p_application_id IN NUMBER
    );

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
    );

    PROCEDURE archive_vacancy(
        p_vacancy_id IN NUMBER
    );

    PROCEDURE unarchive_vacancy(
        p_vacancy_id IN NUMBER
    );

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
    );

    FUNCTION reset_pass_check(
        p_email IN VARCHAR2
    )return varchar2;






END PKG_ADMIN;
/
