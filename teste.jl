using JuMP, GLPK;
arquivo_atual = 1;


function main()

    for arquivo_atual in 1:10
        nome_arquivo = "arquivosTeste/ocs_$arquivo_atual.txt";
        qntKid,vetorPesos = leArquivo(nome_arquivo);  

        model = Model(GLPK.Optimizer);
        @variable(model, assentos[1:qntKid,1:qntKid],Bin);
        @variable(model, W);
        @variable(model, Wi[1:2]);
    
        for i in 1:qntKid
            @constraint(model, sum(assentos[i,j] for j in 1:qntKid) ==  1);
        end
    
        for j in 1:qntKid
            @constraint(model,sum(assentos[i,j] for i in 1:qntKid) == 1);
        end
    
        for k in 1:2
            @constraint(model, Wi[k] == sum(vetorPesos[p]*sum(assentos[p,j] for j in 1:qntKid) for p in Int((k-1)*qntKid/2 + 1):Int(k*qntKid/2)));
        end
    
        for l in 1:2
            @constraint(model, W >= Wi[l]);
        end
    
        @objective(model,Min,W);
        optimize!(model);
        status = termination_status(model)
        println("Status da otimização $arquivo_atual: ", status)
        println("Valor da função objetivo: ", objective_value(model))
    end

   
end


function leArquivo(nome_arquivo)
    qntKid = 0
    vetorPesos = []
    open(nome_arquivo, "r") do arquivo
        qntKid =parse(Int, readline(arquivo));
        vetorPesos = parse.(Int, split(readline(arquivo)));
    end

    return qntKid, vetorPesos;
end

main()