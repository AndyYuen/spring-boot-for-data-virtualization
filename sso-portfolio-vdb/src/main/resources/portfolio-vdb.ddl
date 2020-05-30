CREATE DATABASE Portfolio OPTIONS (ANNOTATION 'The Portfolio VDB'); USE
DATABASE Portfolio;

CREATE ROLE ReadRole WITH FOREIGN ROLE ReadRole; 
CREATE ROLE StockRole WITH FOREIGN ROLE StockRole;

CREATE FOREIGN DATA WRAPPER rest; CREATE FOREIGN DATA WRAPPER postgresql;


CREATE SERVER "sampledb" FOREIGN DATA WRAPPER postgresql; 
CREATE SERVER "quotesvc" FOREIGN DATA WRAPPER rest;


CREATE SCHEMA marketdata SERVER "quotesvc"; 
CREATE SCHEMA accounts SERVER "sampledb";

CREATE VIRTUAL SCHEMA Portfolio;


SET SCHEMA marketdata;

IMPORT FROM SERVER "quotesvc" INTO marketdata;


SET SCHEMA accounts;

IMPORT FROM SERVER "accountdb" INTO accounts OPTIONS (
	"importer.useFullSchemaName" 'false',
	"importer.tableTypes" 'TABLE,VIEW');


SET SCHEMA Portfolio;

                  
CREATE VIEW StockPrice (
	symbol string PRIMARY KEY,
	price double,
	CONSTRAINT ACS ACCESSPATTERN (symbol)
	) AS  
		SELECT p.symbol, y.price
		FROM accounts.FIN_PRODUCT as p, TABLE(call invokeHttp(action=>'GET', endpoint=>QUERYSTRING('quote', p.symbol as "symbol", 'bq0bisvrh5rddd65fs70' as "token"), headers=>jsonObject('application/json' as "Content-Type"))) as x, 
            JSONTABLE(JSONPARSE(x.result,true), '$' COLUMNS price double path '@.c') as y;
            

CREATE VIEW CustomerHoldings (
	LastName string PRIMARY KEY,
	FirstName string,
	symbol string,
	ShareCount integer,
	StockValue double
	) AS 
		SELECT c.lastname as LastName, c.firstname as FirstName, p.symbol as symbol, h.shares_count as ShareCount, (h.shares_count*sp.price) as StockValue 
            FROM fin_Customer c JOIN fin_Account a on c.SSN=a.SSN 
            JOIN fin_Holdings h on a.fin_account_id = h.fin_account_id 
            JOIN fin_product p on h.fin_product_id=p.id 
            JOIN StockPrice sp on sp.symbol = p.symbol
            WHERE a.type='Active';

CREATE VIEW AccountValues (
	LastName string PRIMARY KEY,
	FirstName string,
	StockValue double
	) AS
		SELECT LastName, FirstName, sum(StockValue) as StockValue 
            FROM CustomerHoldings
            GROUP BY LastName, FirstName;
            

GRANT SELECT ON SCHEMA Portfolio TO ReadRole; 
GRANT SELECT ON TABLE "Portfolio.StockPrice" TO StockRole;


