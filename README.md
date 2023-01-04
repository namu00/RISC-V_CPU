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
> + ### 컴퓨터 구조
>    Memory - CPU - Peripheral (I/O Device)  
>    + CPU  
>      CPU는 범용레지스터 (General Purpose Register),  
>      PC (Program Counter, in RISC-V),  
>      ALU (Arithmetic Logical Unit)  
>      으로 구성되어있다.
> 
>    + Memory  
>      CPU가 수행할 명령어들을 Load해놓고 대기하는 Table이다.  
>      어셈블리 명령어들이 저장되어있다.  
>      기본 주소 접근단위는 1byte이다.
>
>    + Peripheral (I/O Device)  
>      컴퓨터 주변장치들을 모두 Peripheral이라고 부른다.  
>      GPU, USB, Monitor등등이 있다.  
>
> + ### RISC vs CISC 
>   ||CISC|RISC|  
>   |:---:|:---:|:---:| 
>   |명령어| Simple to complex instructions| Simple instructions|  
>   |명령어 길이| Variable| Fixed |  
>   |명령어 개수| Many | Reduced|  
>   |메모리 접근| Memory to Memory 연산 지원| load/store 명령어만 접근 가능|  
>   |컴파일된 프로그램 크기| Small | Large |  
>   |하드웨어 복잡도| High | Low |  
>
> + ### 32-bit / 64-bit Architecture?
>    컴퓨터가 한 번에 연산할 수 있는 데이터(register) 크기
>
> + ### CPU의 정수 대/소 비교
>     비교대상의 자료형태를 Signed-Signed / Unsigned-Unsigned처럼 통일해야만 한다.  
>     뺄셈을 이용해(A - B, Calculated by ALU) 상태레지스터(Flag)를 설정하고, 대/소를 비교한다. 
>  
>   |Status|Flag (RISC-V)|Description|    
>   |:---:|:---:|:---:|  
>   |Zero| Z | A - B = 0 즉, A == B|  
>   |Negative| N | A - B < 0 (Signed/Unsigned 무관) |  
>   |Carry| C | 1: Unsigned Overflow<br> 0: Unsigned Underflow |  
>   |Overflow| V | if V == 1: <br>Signed Overflow<br> or Signed Underflow |  
> 
