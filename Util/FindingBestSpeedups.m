function [Ss , Sns ] = FindingBestSpeedups( Tns, Ts, speedup )

    A = [];
    epsilon = 0.5;

    for i=0:1:100
        for j=0:1:100
           [SS, SNS, Z, S] = SpeedupOptimization(Tns, Ts, speedup, 100, i, j, 0);
           if (SNS <= speedup) || (SNS >= 2*speedup) || (S <= (speedup - epsilon)) || (S >= (speedup + epsilon))
              continue;
           end;
           
           A_add = [ SS ; SNS ; S ; Z; i; j ];
           
           if ( ~ existElement( A_add , A ) ) 
               A = [A A_add];
           end           
           
        end
    end
    
    if isempty(A)
        A = [10; 10; 10; 10; 1; 1];
    end
    
    printSolutions(A);   
    
    prompt = 'Choose one of the options above:\n Option ';
    user_choice = input(prompt);
    loop = 1;
    while (loop)

        if ( user_choice > size(A,2) || user_choice <= 0 )
            fprintf('\nInvalid Option!\n\n');
            printSolutions(A);
            prompt = 'Choose one of the options above:\n Option ';
            user_choice = input(prompt);
        else 
            loop = 0;
        end
    end
    Ss = A(1, user_choice);
    Sns = A(2, user_choice);
end

function exist = existElement( A_add , A )

    exist = 0;

    for k = 1:size(A,2)
        if ( A(1,k) == A_add(1) ) && ( A(2,k) == A_add(2) )
            exist = 1;
            break;
        end
    end

end

function printSolutions(A)
    fprintf('Possible options:\n');
    for i = 1:size(A,2)
        fprintf('Option %d - Ss %d and Sns %d with estimated Final Speed-up %f and minimum argument Z = %f and lambda1 = %d and lambda2 = %d\n', i, A(1,i), A(2,i), A(3,i), A(4,i), A(5,i), A(6,i));
    end
end
