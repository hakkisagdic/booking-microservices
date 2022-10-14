using FluentValidation;
using Passenger.Passengers.Models;

namespace Passenger.Passengers.Features.CompleteRegisterPassenger;

public class CompleteRegisterPassengerCommandValidator : AbstractValidator<CompleteRegisterPassengerCommand>
{
    public CompleteRegisterPassengerCommandValidator()
    {
        CascadeMode = CascadeMode.Stop;

        RuleFor(x => x.PassportNumber).NotNull().WithMessage("The PassportNumber is required!");
        RuleFor(x => x.Age).GreaterThan(0).WithMessage("The Age must be greater than 0!");
        RuleFor(x => x.PassengerType).Must(p => p.GetType().IsEnum &&
                                                p == Enums.PassengerType.Baby ||
                                                p == Enums.PassengerType.Female ||
                                                p == Enums.PassengerType.Male ||
                                                p == Enums.PassengerType.Unknown)
            .WithMessage("PassengerType must be Male, Female, Baby or Unknown");
    }
}
