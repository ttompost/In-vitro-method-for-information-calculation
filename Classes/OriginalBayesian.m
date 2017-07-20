classdef OriginalBayesian < BayesianNeuron
    % Original bayesian neuron model
    
    
    methods
        function bn = OriginalBayesian(vars)
            bn = bn@BayesianNeuron(vars);
            bn.dof = 2;
            bn.resetcondition = @Neuron.bayesianresetc;
            bn.resetfunction = @Neuron.bayesianresetf;
        end    
        
        function dydt = neuronfunction(bn, Y, inp)
            % Y=2D
            % Y(1)=L, Y(2)=G
            ron =bn.vars.ron;
            roff=bn.vars.roff;
            theta=bn.vars.theta;
            dydt(1)=(ron*(1+exp(-Y(1)))-roff*(1+exp(Y(1)))+inp-theta);
            dydt(2)=(ron*(1+exp(-Y(2)))-roff*(1+exp(Y(2))));
        end
    end
    
end

