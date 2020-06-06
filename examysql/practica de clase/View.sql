use farma_dmart_ped;

SELECT  
	p.Cod_prod, CONCAT(p.Nom_prod, ' ', p.Concent, ' ', p.Presentac, ' frac', p.Fracciones ) as Nom_prod, 
    p.Prec_compra, p.Prec_venta,
	c.Nom_cat,
	f.Nom_fam
FROM farmadb.producto as p  
	inner join farmadb.categoria as c on p.Cat_id= c.Cat_id 
    inner join farmadb.familia as f on c.Fam_id= f.Fam_id;

SELECT 
	date_format(pe.Fecha_confirm, '%Y-%m-%d')  as Fecha
    ,DAYNAME(pe.Fecha_confirm ) AS DIA_SEMANA
	,MONTH(pe.Fecha_confirm ) AS COD_MES
	,MONTHNAME(pe.Fecha_confirm ) AS DES_MES
	,QUARTER( pe.Fecha_confirm ) AS COD_TRIMESTRE
	,CONCAT('Trimestre ', QUARTER(pe.Fecha_confirm )) AS DES_TRIMESTRE
	,YEAR(pe.Fecha_confirm ) AS COD_ANIO
FROM farmadb.PEDIDO as pe WHERE pe.Fecha_confirm IS NOT NULL
       GROUP BY date_format(pe.Fecha_confirm, '%Y-%m-%d')
       ORDER BY date_format(pe.Fecha_confirm, '%Y-%m-%d');

SELECT 
DT.DTiem_id,
DP.DProd_id,
DCLI.DCli_id,
DVEND.DVend_id,
sum(G.Ventas) as VENTAS,
sum(G.Cantidad) as CANT_UNID,
sum(G.Costos) as COSTOS,
sum(G.Descuentos) as DESCTOS,
sum(G.min_confirmacion) as CANT_MIN_CONFIRM,
sum(G.min_despacho) as CANT_MIN_DESPACH,
sum(G.horas_entrega2) as CANT_HORAS_ENTREGA,
COUNT(DISTINCT G.Nom_cli) AS Cant_clientes
FROM (
	SELECT  
		date_format(pe.Fecha_crea, '%Y-%m-%d') AS Fecha
		,TIMESTAMPDIFF(MINUTE,pe.Fecha_crea, pe.Fecha_confirm) AS min_confirmacion
		,TIMESTAMPDIFF(MINUTE,pe.Fecha_confirm, pe.Fecha_envio) AS min_despacho
		,ROUND( time_to_sec( TIMEDIFF(pe.Fecha_entrega, pe.Fecha_envio) ) /3600, 2) as horas_entrega2
		,p.Cod_prod
		 ,p.Nom_prod
		 ,c.Nom_cat
		 ,f.Nom_fam
		,ped.Cantidad
		,ped.Cantidad*ped.Prec_compra_un as Costos
		,ped.Cantidad*(ped.Prec_venta_un - ped.Total_desc_un ) as Ventas
		,ped.Cantidad*(ped.Total_desc_un ) as Descuentos
        ,cli.Nom_cli
        ,v.Nom_vend
	FROM farmadb.PEDIDO as pe
		inner join farmadb.PEDIDO_DET as ped on pe.Ped_id= ped.Ped_id 
		inner join farmadb.PRODUCTO as p on ped.Prod_id= p.Prod_id 
		inner join farmadb.CATEGORIA as c on p.Cat_id= c.Cat_id 
		inner join farmadb.FAMILIA as f on c.Fam_id= f.Fam_id 
        inner join farmadb.CLIENTE as cli on pe.Cli_id= cli.Cli_id 
        inner join farmadb.VENDEDOR as v on pe.Vend_id= v.Vend_id 
	)  AS G
    
    inner join DPRODUCTO AS DP ON G.Cod_prod = DP.Cod_prod
    inner join DTIEMPO AS DT ON G.Fecha = DT.Fecha
    inner join DCLIENTE AS DCLI ON G.Nom_cli = DCLI.Nom_cli
    inner join DVENDEDOR AS DVEND ON G.Nom_vend = DVEND.Nom_vend
	GROUP BY DP.DProd_id, DT.DTiem_id, DCLI.DCli_id, DVEND.DVend_id
;

    
