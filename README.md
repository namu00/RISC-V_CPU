# RISC-V_computer_architecture
> Studyroom for Computer Architecture with RISC-V

## Textbook     
|Title|Writer|Publisher|Translate|Development Env|  
|:---:|:---:|:---:|:---:|:---:|    
|원리부터 설계까지 쉽고 명확한 <br> 컴퓨터구조|서태원|도서출판 <br>홍릉|-|RISC-V|  
|컴퓨터 구조 및 설계| David A.Patterson <br> JohnL. Hennessy|한티미디어| 박명순 <br> 외 3명|MIPS|  

# Summury

 ## Terms  
>     ALU: Arithmetic Logical Unit  
>     ISA: Instruction Set Architecture
>     RISC: Reduced Instruction Set Computer
>     CISC: Complex Instruction Set Computer
>     PC: Program Count (부팅시 사용할 명령어 address 저장소 in RISC)
>     IP: Instruction Point (부팅시 사용할 명령어 address 저장소 in CISC)
 ## Chapter1.  
> + ### RISC vs CISC 차이점
> ||CISC|RISC|  
> |:---:|:---:|:---:| 
> |명령어| Simple to complex instructions| Simple instructions|  
> |명령어 길이| Variable| Fixed |  
> |명령어 개수| Many | Reduced|  
> |메모리 접근| Memory to Memory 연산 지원| load/store 명령어만 접근 가능|  
> |컴파일된 프로그램 크기| Small | Large |  
> |하드웨어 복잡도| High | Low |  

> + ### 32-bit / 64-bit Architecture?
>    컴퓨터가 한 번에 연산할 수 있는 데이터(register) 크기

> + ### 