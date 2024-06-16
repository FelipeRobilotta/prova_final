TELA DE AULA 
botão Cadastrar:
IF  btnCadastrar  <> 0 THEN
	
	Open(frmAula,"Incluir",tblCadastroAula.cidAula,cAula)
	locPesquisar()

END

Botão modificar
IF TableCount(tblCadastroAula) = 0 THEN
	Info("Tabela vazia. ")
	RETURN
END
IF NOT TableSelectCount(tblCadastroAula) > 0 THEN
	Info("Nada foi Selecionado! ")
	RETURN
END
IF TableSelectCount(tblCadastroAula) > 0 THEN
	id is string = tblCadastroAula.cAula
	Open(frmAula,"Modificar",tblCadastroAula.cidAula,cAula) // Enviando todo registro selecionado para a tela frm
	
	locPesquisar()
	TableSelectPlus(tblCadastroAula,TableSeek(tblCadastroAula.cidAula,id)) // selecionando a linha que foi modificada
	

END

Botão Consultar
IF TableSelectCount(tblCadastroAula) = 0 THEN
	Info("Nada foi selecionado")
	RETURN	
END

Open(frmAula,"Consultar",tblCadastroAula.cidAula,cAula)


Botão Apagar
PROCEDURE locApagar()

IF TableSelectCount(tblCadastroAula) = 0 THEN
	Info("Nenhum item selecionado")
	RETURN
END
IF TableCount(tblCadastroAula) > 0 THEN
	IF  YesNo("Podemos Apagar esse codigo? ") THEN
		
	verificarAula is boolean
	verificarAula = locVerificarAula()
	IF verificarAula = True THEN
		Info("Existe Aula vinculada à turma. Para poder excluir, será necessário desvinculá-lo primeiro. ")
		RETURN
		END
			
		
		HourGlass(True)
		ds is Data Source
		sqldelete is string = "delete from Aula where idAula = %1"
		
		sqldelete = StringBuild(sqldelete,tblCadastroAula.cidAula)
		
		HFreeQuery(ds)
		IF NOT HExecuteSQLQuery(ds,ConectarBanco.Conexao,hQueryWithoutCorrection,sqldelete)
		Info(HErrorInfo())
		HFreeQuery(ds)
		RETURN
	ELSE
		Info("Registro excluido com sucesso! ")
	END
	HFreeQuery(ds)
	ExecuteProcess(btnPesquisar,trtClick)
END

END


Tela form 

Botão Gravar

SWITCH operacao
	
	CASE "Incluir"
	locverificar()
	
	CASE "Modificar"
	locverificar()
	
	OTHER CASE
		
END

locverificar()

PROCEDURE locverificar()
verificarAula is string = ""
ds is Data Source

locAula()


verificarAula =[
	
	select 
	nomeAula
	from 
	Aula
	where nomeAula = '%1'
]

verificarAula = StringBuild(verificarAula,edtAula)

IF NOT HExecuteSQLQuery(ds,ConectarBanco.Conexao,hQueryWithoutCorrection,verificarAula) THEN
	Info("Erro ao resgatar dados!")
	Close(MyWindow)
	
ELSE
	HReadFirst(ds)
	
	IF HFound(ds) THEN
		IF operacao = "Incluir" THEN
			NextTitle("Atenção")
			Warning("Aula informada já existe no Cadastro, por favor informe outra Aula! ")
			ReturnToCapture(edtAula)
		ELSE IF operacao = "Modificar" THEN
			IF edtAula = cAula THEN
				locGravar()
				ELSE
				
				NextTitle("Atenção")
				Warning("Aula informada já existe no Cadastro, por favor informe outra Aula! ")
				ReturnToCapture(edtAula)
		END
	END
	END
END
	IF operacao = "Incluir" THEN
		locCadastrar()
	ELSE
		locGravar()
END

locCadastrar()

PROCEDURE locCadastrar()

ds is Data Source

sqlCadastrar is string = ""

sqlCadastrar =[
	insert into 
		Aula
		(
	 nomeAula
	 	)
	 values
	 	(
	 	'%1'
	 	)

]

sqlCadastrar = StringBuild(sqlCadastrar,...
edtAula...
)

IF NOT HExecuteSQLQuery(ds,ConectarBanco.Conexao,hQueryWithoutCorrection,sqlCadastrar) THEN
	ErrorInfo(errInfo)
ELSE
	
	Info("Cadastro realizado com sucesso")
END
Close()




PROCEDURE locGravar()

ds is Data Source 

sqlModificar is string = [
	update
		 Aula
	set
		nomeAula  = '%1'
	where
		idAula = %2

]
sqlModificar = StringBuild(sqlModificar,...
edtAula,...
cidaula...
)

IF HExecuteSQLQuery(ds,ConectarBanco.Conexao,hQueryWithoutCorrection,sqlModificar) THEN
	Info("Aula modificada com sucesso! ")
	Close(MyWindow)
ELSE
	Info("Erro ao modificar Aluno! ")
	RETURN
END
