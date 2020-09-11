% get SWE data from pillows or courses
function [SWE,datevals]=getSWE(P,sensor,startdate,enddate,conn)
%
% input
%   P - CDEC code for pillows or courses, has to be cell array
%   sensor - 'pillow' or 'course'
%   startdate,enddate - date range in form that SQL Server understands
%       (e.g. 'mm/dd/yy' or ISO 'yyyymmdd')
%   matlab connection object
%
% output
%   SWE - Nx3 matrix, column 1 is snow water equivalent, col 2 is index
%       the P vector, col 3 is index into the datevals vector
%   datevals - vector of MATLAB datenums at which the SWE measurements are
%       available

% which tables?
if strcmp(sensor,'pillow')
    tstr1='SELECT ALL MeasDate,SWEmm from PillowSWE WHERE';
    tstr2='AND MeasDate BETWEEN';
elseif strcmp(sensor,'course')
    tstr1='SELECT ALL MeasDate,SWEmm from CourseSWE WHERE';
    tstr2='AND MeasDate BETWEEN';
else
    error('function getSWE: sensor %s invalid',sensor)
end

% Make connection to database.  Note that the password and username are
% needed with the JDBC connection.
% conn=database.ODBCConnection('SierraNevadaSnow',username,passwd);

% read data from database, station by station
np=length(P);
sv=[];
dv=[];
pv=[];
for k=1:np
    % query string
    qstr=sprintf('%s CDEC=''%s'' %s ''%s'' and ''%s''',...
        tstr1,char(P(k)),tstr2,startdate,enddate);
    % read data for station P(k)
    e = exec(conn,qstr);
    e = fetch(e);
%     close(e);
% e = fetch(conn,qstr);
% close(conn)
    % put the data into the sv vector, the station # into pv, and the date
    % into dv
     if ~strcmp(e.Data,'No Data')
%     if ~isempty(e.Data)
        sv=cat(1,sv,table2array(e.Data(:,2)));
        pv=cat(1,pv,ones(height(e.Data(:,2)),1)*k);
        dv=cat(1,dv,datenum(table2cell(e.Data(:,1))));
    end
end
SWE=[sv pv dv];
datevals=unique(dv);
% replace the date by its index into the date vector
for k=1:length(datevals)
    t=SWE(:,3)==datevals(k);
    SWE(t,3)=k;
end