
  CREATE OR REPLACE EDITIONABLE FUNCTION "CAREERS"."DETECT_DOCUMENT_MIME_TYPE" (
    p_blob      in blob,
    p_filename  in varchar2 default null
) return varchar2
is
    l_header varchar2(200);
    l_name   varchar2(1000) := lower(p_filename);
begin
    if p_blob is null or dbms_lob.getlength(p_blob) = 0 then
        return null;
    end if;

    l_header := rawtohex(dbms_lob.substr(p_blob, 64, 1));

    -- pdf
    if l_header like '25504446%' then
        return 'application/pdf';

    -- jpg / jpeg
    elsif l_header like 'FFD8FF%' then
        return 'image/jpeg';

    -- png
    elsif l_header like '89504E47%' then
        return 'image/png';

    -- gif
    elsif l_header like '47494638%' then
        return 'image/gif';

    -- bmp
    elsif l_header like '424D%' then
        return 'image/bmp';

    -- tiff
    elsif l_header like '49492A00%' or l_header like '4D4D002A%' then
        return 'image/tiff';

    -- webp
    elsif substr(l_header, 1, 8) = '52494646'
       and substr(l_header, 17, 8) = '57454250' then
        return 'image/webp';

    -- docx is zip based
    elsif l_header like '504B0304%'
       or l_header like '504B0506%'
       or l_header like '504B0708%' then

        if l_name like '%.docx' then
            return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        else
            return 'application/zip';
        end if;

    -- old .doc word files
    elsif l_header like 'D0CF11E0A1B11AE1%' then

        if l_name like '%.doc' then
            return 'application/msword';
        else
            return 'application/vnd.ms-office';
        end if;

    else
        return 'application/octet-stream';
    end if;
end;
/
