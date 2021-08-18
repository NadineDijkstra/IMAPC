function [V,A,IQ,C,IC] = get_descriptives(data)


V = mean(data.ima_practice(:,2));
A = data.age;
IQ = data.ima_question;
C = data.comments;
IC = data.ima_check;