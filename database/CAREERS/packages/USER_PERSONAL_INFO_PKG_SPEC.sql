
  CREATE OR REPLACE EDITIONABLE PACKAGE "CAREERS"."USER_PERSONAL_INFO_PKG" As


    PROCEDURE Complete_account_data(v_first_name account.first_name%type, v_second_name account.SECOND_NAME%type ,
    v_last_name account.LAST_NAME%type, v_date_of_birth account.DATE_OF_BIRTH%TYPE, v_gender account.gender%type,
    v_email account.email%TYPE, v_home_telephone account.HOME_TELEPHONE%TYPE, v_address account.ADDRESS%TYPE,  v_city_id account.CITY_ID%type,
    v_nat_id account.NATIONAL_ID%type, v_passport_number account.PASSPORT_NUMBER%type, v_country_id account.country_id%type,
    v_country_phone_code account.COUNTRY_PHONE_CODE_ID%type,  v_mobile_telephone account.mobile_telephone%type,
    v_user_id account.id%type);


    PROCEDURE Save_Personal_data(v_marital_status personal_info.marital_status%type, v_military_status personal_info.MILITARY_STATUS%type,
    v_mother_full_name personal_info.MOTHER_FULL_NAME%type,v_image VARCHAR2 , v_account_id number, v_personal_id OUT NUMBER);

    Procedure save_education_degree(v_education_level education_degree.education_level%type,
    v_education_field education_degree.education_field%type, v_grad_year education_degree.GRADUATION_YEAR%type,
    v_grade education_degree.EDUCATION_GRADE%type, v_university education_degree.UNIVERSITY%type,
    v_other_field education_degree.OTHER_EDUCATION_FIELD%type, v_personal_id education_degree.PERSONAL_ID%type, v_Grad_image Varchar2);


    PROCEDURE Update_Personal_data(v_marital_status personal_info.marital_status%type, v_military_status personal_info.MILITARY_STATUS%type,
    v_mother_full_name personal_info.MOTHER_FULL_NAME%type,v_image VARCHAR2 , v_id NUMBER);

    PROCEDURE Update_Education_data(v_edu_level_id Education_degree.EDUCATION_LEVEL%type, v_edu_field_id Education_degree.EDUCATION_FIELD%type,
        v_grad_year Education_degree.GRADUATION_YEAR%type, v_edu_grade Education_degree.EDUCATION_GRADE%type,
        v_university Education_degree.UNIVERSITY%type, v_other_field Education_degree.OTHER_EDUCATION_FIELD%type ,v_image VARCHAR2, v_id NUMBER);

end user_personal_info_pkg;
/
