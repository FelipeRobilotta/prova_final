Cadastro de Turma 

Botão Cadastro Turma:
IF btnCadastrar <> 0 THEN
	
	Open(frmTurma,"Incluir","","","")
	//tblCadastroTurma.cidTurma,cSituacao)
	
	
	
B
END

Botão Modificar: 
IF btnModificar <> 0 THEN
	Open(frmTurma,"Modificar",cidTurma,cSituacao,cTurma)
	locPesquisar()
	

END

Botão Consultar:

IF TableSelectCount(tblCadastroTurma) = 0 THEN
	Info("Nada foi selecionado")
	RETURN	
END

IF btnModificar <> 0 THEN
	
Open(frmTurma,"Consultar",cidTurma,cSituacao,cTurma)
locPesquisar()
END



PROCEDURE locApagar()

IF TableSelectCount(tblCadastroTurma) = 0 THEN
	Info("Podemos apagar item selecionado")
	RETURN
END

verificarAluno is boolean
verificarAula is boolean
dsapagar1 is Data Source
dsapagar2 is Data Source


IF TableCount(tblCadastroTurma) > 0 THEN
	IF YesNo("Podemos apagar o esse cadastro? ") THEN
		HourGlass(True)
		
	ELSE 
		RETURN
	END
		
		// excluindo Aula
		verificarAula = locVerificarAula()
		verificarAluno = locVerificarAluno()
		
		
		IF verificarAula = True OR verificarAluno = True THEN
			locQuantidadeAluno()
			IF AulaQuantidade = "" THEN		
				IF YesNo ("Existe " + alunoQuantidade + " Alunos na Turma." , "Deseja Excluir?" )	= False THEN
					RETURN
				END
			
			ELSE
				IF YesNo ("Existe " + alunoQuantidade + " Alunos  na aula de  " + AulaQuantidade + ".", "Deseja Excluir?") = False
				RETURN
			END
			END
				
			//			if yesno("Existe " + alunoQuantidade + " Alunos  na aula de  " + AulaQuantidade + ".", "Deseja Excluir")
			//				HourGlass(True)
			//			end
			//			
			//	IF YesNo("Existe  Aula vinculada com a turma, deseja excluir mesmo assim? ")
			
			sqlDelete is string = "Delete from aulaturma where idturma = %1"
			
			sqlDelete = StringBuild(sqlDelete,tblCadastroTurma.cidTurma)
			
			IF NOT HExecuteSQLQuery(dsapagar1,ConectarBanco.Conexao,hQueryWithoutCorrection,sqlDelete)
				Info(HErrorInfo)
				HFreeQuery(dsapagar1)
				RETURN
				HFreeQuery(dsapagar1)
				ExecuteProcess(btnPesquisar,trtClick)
			END
			
		END
		
		
		//excluindo Aluno
		verificarAluno = locVerificarAluno()
		
		IF verificarAluno = True THEN
//			IF YesNo("Existe Aluno cadastrado na turma, deseja excluir mesmo assim? ") THEN
//				HourGlass(True)
//				
				dsapagar3 is Data Source 
				sqlDelete3 is string = "update aluno set idturma = null where idturma = %1"
				
				sqlDelete3 = StringBuild(sqlDelete3,tblCadastroTurma.cidTurma)
				
				IF NOT HExecuteSQLQuery(dsapagar3,ConectarBanco.Conexao,hQueryWithoutCorrection,sqlDelete3)
					Info(HErrorInfo)
					HFreeQuery(dsapagar3)
					RETURN
					
					
					
					HFreeQuery(dsapagar3)
					ExecuteProcess(btnPesquisar,trtClick)
				END
			END
		END
		
		
		
		// Excluindo Turma
		
		sqlDelete2 is string = "Delete from turma where idTurma = %1"
		
		sqlDelete2 = StringBuild(sqlDelete2,tblCadastroTurma.cidTurma)
		
		IF NOT HExecuteSQLQuery(dsapagar2,ConectarBanco.Conexao,hQueryWithoutCorrection,sqlDelete2)
			Info(HErrorInfo)
			HFreeQuery(dsapagar2)
			RETURN
			
		ELSE
			Info("Registro excluido com sucesso. ")
			
		END
		HFreeQuery(dsapagar2)
		ExecuteProcess(btnPesquisar,trtClick)

PROCEDURE locPesquisar()

status is string
Pesquisar is string

TableDeleteAll(tblCadastroTurma)
WHEN EXCEPTION IN 
	
	
	Pesquisar = [
		SELECT 
		
		T.iDTurma 
		,T.numeroTurma
		,P.nomecompleto
		,T.bitativo
		,P.idRegistro 
		FROM 
		turma AS T
		LEFT JOIN Professor AS P
		ON T.idRegistro = P.IdRegistro
		
		
		WHERE 1 = 1 
		
	]
	IF edtTurma <> "" THEN
		Pesquisar += " And numeroTurma like '%" + edtTurma + "%'"
	END
	
	ds is Data Source 
	HFreeQuery(ds)
	
	IF NOT HExecuteSQLQuery(ds,ConectarBanco.Conexao,hQueryWithoutCorrection,Pesquisar) THEN
		Error("Erro ao se conectar")
		HFreeQuery(ds)
		RETURN
	ELSE
		HReadFirst(ds)
		FOR EACH ds
			IF ds.bitativo = 1 THEN
				status = "Aberta"
			ELSE
				status = "Fechado"
			END
			
			TableAddLine(tblCadastroTurma,ds.idTurma,ds.numeroTurma,ds.nomeCOmpleto,status)
			
			
		END
		
	END
	HFreeQuery(ds)	
	
DO 
	Info(ErrorInfo())
	
END


Tela form
Botão gravar

IF edtTurma = "" THEN
	Info("Obrigatorio cadastrar uma turma")
	ReturnToCapture(edtTurma)
END

IF cmbProfessor = 1 THEN
	Info("Obrigatorio Cadastrar um professor na Turma")
	ReturnToCapture(cmbProfessor)
END

IF operacao = "Incluir" AND cSelecionar = 0 THEN
	Info("Obrigatorio incluir pelo menos um aluno para criar uma turma")
	ReturnToCapture(cSelecionar)
END


IF operacao = "Incluir" THEN
	
	locVerificarSeExiste()
	
	
ELSE IF operacao = "Modificar"
	locVerificarSeExiste()
	//

END



locVerificarSeExiste()

verificarAula is string = ""
ds is Data Source

verificarAula =[
	
	select 
	numeroTurma
	from 
	turma
	where numeroTurma = '%1'
]

verificarAula = StringBuild(verificarAula,edtTurma)

IF NOT HExecuteSQLQuery(ds,ConectarBanco.Conexao,hQueryWithoutCorrection,verificarAula) THEN
	Info("Erro ao resgatar dados!")
	Close(MyWindow)
	
ELSE
	HReadFirst(ds)
	
	IF HFound(ds) THEN
		IF operacao = "Incluir" THEN
			NextTitle("Atenção")
			Warning("Turma informada já existe no Cadastro, por favor informe outra Turma! ")
			ReturnToCapture(edtTurma)
		ELSE IF operacao = "Modificar" THEN
			IF edtTurma = cturma THEN
				
				locModificar()
			ELSE
				
				NextTitle("Atenção")
				Warning("Turma informada já existe no Cadastro, por favor informe outra Turma! ")
				ReturnToCapture(edtTurma)
			END
		END
	END
END
IF operacao = "Incluir" THEN
	
	locCadastrar()
	locIncluir()
ELSE
	locModificar()
END



PROCEDURE locModificar()

ds is Data Source 

sqlmodificar is string

sqlmodificar = [
	
	update
	turma
	set
	numeroTurma 		='%1'
	,idRegistro		= %2
	where
	idTurma			=%3
	
]

sqlmodificar = StringBuild(sqlmodificar,...
edtTurma,...
cmbProfessor..StoredValue,...
cidTurma)

IF NOT HExecuteSQLQuery(ds,ConectarBanco.Conexao,hQueryWithoutCorrection,sqlmodificar) THEN
	
	Info("Erro ao modificar Professor! ")
	RETURN
END

sqlmodificarAluno is string = ""
dsAluno is Data Source

FOR i = 1 TO TableCount(tblAlunos)
	TableSelectPlus(tblAlunos,i)
	
	IF tblAlunos.cSelecionar = True THEN
		
		sqlmodificarAluno = [
			
			update 
			aluno
			set
			idturma  		= %1
			where 
			idmatricula 	= %2
			
		]
		

		sqlmodificarAluno = StringBuild(sqlmodificarAluno,...
		cidTurma,...
		tblAlunos.cidMatricula[i])
		
		
		IF NOT HExecuteSQLQuery(dsAluno,ConectarBanco.Conexao,hQueryWithoutCorrection,sqlmodificarAluno) THEN
	
			Info("Erro ao modificar Cadastro! ")
			RETURN
		END
	ELSE 
		sqlmodificarAluno = [
			
			update 
			aluno
			set
			idturma  		= NULL
			where 
			idmatricula 	= %1
			
		]
		
		
		sqlmodificarAluno = StringBuild(sqlmodificarAluno,...
		tblAlunos.cidMatricula[i])
		
		
		
		IF NOT HExecuteSQLQuery(dsAluno,ConectarBanco.Conexao,hQueryWithoutCorrection,sqlmodificarAluno) THEN
		
		Error(ErrorInfo)
			
			
			
			
		
		END
	END
END

Info("Cadastro Modificado com Sucesso! ")
Close(MyWindow)



PROCEDURE locCadastrar()

ds is Data Source 

Cadastrar is string =[
	
	insert into 
		turma(
	numeroTurma
	,bitativo
	,idRegistro
		)
	values
		(
	'%1'
	,'%2' 
	,'%3'
	 
	 )
]

// output inserted.* pegar o id do que foi inserido para usar ele em outra tabela

Cadastrar = StringBuild(Cadastrar,...
edtTurma,...
rdbTurma,...
cmbProfessor..StoredValue)

IF NOT HExecuteSQLQuery(ds,ConectarBanco.Conexao,hQueryWithoutCorrection,Cadastrar) THEN
	Error(HErrorInfo())
	HFreeQuery(ds)
	RETURN	
ELSE

	verificarAula is string = ""
	ds1 is Data Source
	
	verificarAula =[
		
		select 
		idturma
		,numeroTurma
		from 
		turma
		where numeroTurma = '%1'
	]
	
	verificarAula = StringBuild(verificarAula,edtTurma)
	
	IF NOT HExecuteSQLQuery(ds1,ConectarBanco.Conexao,hQueryWithoutCorrection,verificarAula) THEN
	
	ELSE
		
		HReadFirst(ds1)
		HFound(ds1)
		idTurma = ds1.idTurma		
	END
		
			
END



PROCEDURE locIncluir()

ds is Data Source 
status is int = ""

FOR i = 1 TO TableCount(tblAlunos)
	TableSelectPlus(tblAlunos,i)
	
	IF tblAlunos.cSelecionar = True THEN
			
	IncluirAluno is string =[
		
		update aluno
		
		set 
		idTurma = %1
		where idMatricula = %2
		
		
	]
	
	IncluirAluno = StringBuild(IncluirAluno,idTurma,tblAlunos.cidMatricula[i])
	

		HFreeQuery(ds)
		
		IF NOT HExecuteSQLQuery(ds,ConectarBanco.Conexao,hQueryWithoutCorrection,IncluirAluno) THEN
			
			Error(HErrorInfo())
			HFreeQuery(ds)
			RETURN	
			
		END
	
	END
	
END
Info("Cadastro Realizado com sucesso!")
Close(MyWindow)
RETURN

Close()
